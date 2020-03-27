#encoding: utf-8

class EvaluationsController < ApplicationController
    before_action :user_accept_terms_required!
    before_action :check_has_location, only: :new
    before_action :check_no_current_evaluation_exists, only: [:new, :create]
    before_action :check_plan_subscription, only: [:new, :create, :set_as_normal]
    before_action :find_evaluation, except: [:index, :new, :create]
    before_action :customer_user_cannot_change_published_evaluation, only: [:update, :destroy]
    before_action :can_show_full_reports_restriction, only: [:full_report, :expenses, :dependences]
    helper_method :current_customer

    # GET /evaluations
    # GET /evaluations.json
    def index
        @evaluations = current_customer.customer_evaluations.order('evaluations.id desc')
        session[:left_service_orderitem] = 'theme'
        session[:right_service_orderitem] = 'theme'
        session[:right_service_query] = ''

        respond_to do |format|
            format.html # index.html.erb
            format.json {render json: @evaluations}
        end
    end

    # GET /evaluations/new
    # GET /evaluations/new.json
    def new
        @evaluation = current_customer.customer_evaluations.new

        @evaluation.name = Evaluation.sample_evaluation.name if params[:testing]
        respond_to do |format|
            format.html # new.html.erb
            format.json {render json: @evaluation}
        end
    end

    # GET /evaluations/1/edit
    def edit
        @evaluation_services = @evaluation.evaluation_services.order('evaluation_services.position').includes(:service)
    end

    def dashboard
        if @evaluation.evaluation_services.draft.any?
            redirect_to customer_evaluation_path(@evaluation.customer, @evaluation), alert: I18n.t('evaluations.status_menu.dashboard_locked_status')
            return
        end
    end

    def show
        respond_to do |format|
            format.html do
                @not_selected_evaluation_services = fetch_not_selected_evaluation_services
                @evaluation_results = fetch_evaluation_results

                @progress_bar_step = 1
                @progress_bar_step += 1 if @evaluation.evaluation_results.any?
                @progress_bar_step += 1 if @evaluation.evaluation_services.draft.empty?
                @progress_bar_step += 1 if @progress_bar_step > 1 && @evaluation.evaluation_results.ignored.empty? && @evaluation.evaluation_services.draft.empty?
                @progress_bar_step += 1 if @evaluation.is_published?

            end
            format.js do
                if params[:attribute].present? && params[:attribute] == "evaluation_results"
                    @evaluation_results = fetch_evaluation_results
                elsif params[:attribute].present? && params[:attribute] == "evaluation_services"
                    @not_selected_evaluation_services = fetch_not_selected_evaluation_services
                end
            end
            format.json {render json: @evaluation}
            format.pdf do
                @evaluation_results = fetch_evaluation_results

                render :pdf => "list_it_services", :encoding => 'utf8', layout: 'pdf.html.erb', :orientation => 'Landscape'
            end
        end
    end

    def set_as_sample
        return unless current_user.is_admin?
        @evaluation = Evaluation.find(params[:id])

        Evaluation.where(:distinguish_type => Evaluation::TYPES.index(:sample)).each do |e|
            e.update_attribute(:distinguish_type, Evaluation::TYPES.index(:normal))
        end

        @evaluation.update_attribute(:distinguish_type, Evaluation::TYPES.index(:sample))
        redirect_to customer_evaluation_path(current_customer, @evaluation)
    end

    def set_as_normal
        @evaluation = Evaluation.find(params[:id])

        @evaluation.update_attribute(:distinguish_type, Evaluation::TYPES.index(:normal))

        redirect_to customer_evaluation_path(current_customer, @evaluation)
    end

    def recreate_sample_service_set
        @evaluation = Evaluation.find(params[:id])


        @newEvaluation = Evaluation.sample_evaluation.clone_evaluation
        @newEvaluation.name = @evaluation.name
        @newEvaluation.status = Evaluation::STATUSES.index("draft")
        @newEvaluation.published_at = nil
        @newEvaluation.distinguish_type = Evaluation::TYPES.index(:sandbox)

        @newEvaluation.company_id = current_company.id
        @newEvaluation.customer_id = current_customer.id
        @newEvaluation.created_by = current_user.id

        @newEvaluation.save!
        @evaluation.destroy!

        redirect_to customer_evaluation_path(current_customer, @newEvaluation)
    end

    def change_mass

        if (params[:status].to_sym == :active || params[:status].to_sym == :ignored) && (first_branch = current_customer.company_branches.first).nil?
            redirect_to customer_evaluation_path(current_customer, @evaluation, params[:right_filters].permit!), notice: I18n.t('evaluation_results.add_and_select_at_least_one_location')
            return
        end

        if params[:attribute] == 'evaluation_results'
            if params[:selected_result_ids].blank? || params[:selected_result_ids].split(",").empty?
                redirect_to customer_evaluation_path(current_customer, @evaluation, params[:right_filters].permit!), notice: I18n.t('evaluations.no_services_selected')
                return
            end
            @evaluation_results = @evaluation.evaluation_results.where(id: params[:selected_result_ids].split(",")).readonly(false)
            status_index = EvaluationResult::SERVICE_STATUSES.index(params[:status].to_sym)

            @evaluation_results.each do |er|
                er.service_status = status_index
                er.save!

                es = er.evaluation_service
                es.status = status_index
                es.save!

                if params[:status].to_sym == :deactivated
                    if @evaluation.evaluation_results.deactivated.where(service_id: er.service_id).count == @evaluation.evaluation_results.where(service_id: er.service_id).count
                        @evaluation.evaluation_results.where(service_id: er.service_id).each do |er1|
                            er1.destroy!
                        end
                        @evaluation.evaluation_services.where(service_id: er.service_id).each do |es|
                            if (es.cloned_index.blank? or es.cloned_index == '.01')
                                es.update_attributes(:cloned_index => '')
                            else
                                es.destroy!
                            end
                        end
                    end
                end
            end
        elsif params[:attribute] == 'evaluation_services'
            if params[:selected_service_ids].blank? || params[:selected_service_ids].split(",").empty?
                redirect_to customer_evaluation_path(current_customer, @evaluation, params[:left_filters].permit!), notice: I18n.t('evaluations.no_services_selected')
                return
            end

            @evaluation_services = @evaluation.evaluation_services.where(id: params[:selected_service_ids].split(",")).readonly(false)

            status_index = EvaluationService::STATUSES.index(params[:status].to_sym)

            @evaluation_services.each do |es|
                es.status = status_index

                if es.status_name == :active || es.status_name == :ignored
                    EvaluationResult.where(evaluation_id: @evaluation.id, service_id: es.service_id, company_branch_id: first_branch.id, cloned_index: es.cloned_index).first_or_create do |er|
                        er.created = current_user
                        er.updated_by = current_user.id
                        er.cloned_index = es.cloned_index
                    end
                    EvaluationResult.where(evaluation_id: @evaluation.id, service_id: es.service_id, company_branch_id: first_branch.id, cloned_index: es.cloned_index).each do |er|
                        er.service_status = status_index
                        er.save!
                    end
                end
                es.save!
            end
        end

        redirect_to customer_evaluation_path(current_customer, @evaluation, params[:left_filters] ? params[:left_filters].permit! : nil)
    end

    def rshow
        respond_to do |format|
            format.js #
        end
    end

    def full_assessment_report
        @active_evaluation_results = @evaluation.active_evaluation_results.
            joins("LEFT JOIN services ON evaluation_results.service_id = services.id").
            joins("LEFT JOIN theme_services ON theme_services.service_id = services.id").
            joins("LEFT JOIN theme_translations ON theme_services.theme_id=theme_translations.theme_id AND theme_translations.locale='" + I18n.locale.to_s + "'").
            joins("LEFT JOIN themes ON theme_services.theme_id=themes.id")
        if params[:order_by]
            params[:ord] = params[:ord] || 'ASC'
            ord = params[:ord]
            if params[:order_by] == 'id'
                @active_evaluation_results = @active_evaluation_results.order("services.code " + ord)
            elsif params[:order_by] == 'theme'
                @active_evaluation_results = @active_evaluation_results.order("themes.orderno " + ord)
            else
                @active_evaluation_results = @active_evaluation_results.order("evaluation_results.#{params[:order_by]} #{ord}, evaluation_results.id")
            end
        else
            @active_evaluation_results = @active_evaluation_results.order('evaluation_results.id, evaluation_results.cloned_index')
        end

        @graph_pieset = [@active_evaluation_results.where(assessment_status: 0).count, @active_evaluation_results.where(assessment_status: 1).count, @active_evaluation_results.where(assessment_status: 2).count]
        respond_to do |format|
            format.html
            format.pdf do
                render :pdf => "it_services_assessment", :encoding => 'utf8', layout: 'pdf.html.erb', :orientation => 'Landscape', page_size: 'A4', margin: {top: 10, right: 1, bottom: 10, left: 2}
            end
            format.csv do
                headers["Content-Disposition"] = "attachment;filename=FullReport_#{Date.today.strftime("%b_%d_%Y")}.csv"
                headers["Content-Type"] = "text/csv; charset=ISO-8859-1"
            end
        end
    end

    def full_report
        reports = ['gb_used', 'servers_count', 'opex', 'capex', 'hours_intern', 'hours_extern', 'result_dependant_services_count', 'result_depending_services_count']
        if params[:report] && reports.include?(params[:report])
            @evaluation_results = @evaluation.active_evaluation_results.where("evaluation_results.#{params[:report]} is not null and evaluation_results.#{params[:report]} > 0").order("evaluation_results.#{params[:report]} desc").limit(20).includes(:service)
            @evaluation_results = @evaluation.active_evaluation_results.
                joins("LEFT JOIN services ON evaluation_results.service_id = services.id").
                joins("LEFT JOIN theme_services ON theme_services.service_id = services.id").
                joins("LEFT JOIN theme_translations ON theme_services.theme_id=theme_translations.theme_id AND theme_translations.locale='" + I18n.locale.to_s + "'").
                joins("LEFT JOIN themes ON theme_services.theme_id=themes.id").
                where("evaluation_results.#{params[:report]} is not null and evaluation_results.#{params[:report]} > 0")
            if params[:order_by]
                params[:ord] = params[:ord] || 'ASC'
                ord = params[:ord]
                if params[:order_by] == 'id'
                    @evaluation_results = @evaluation_results.order("services.code " + ord)
                elsif params[:order_by] == 'theme'
                    @evaluation_results = @evaluation_results.order("themes.orderno " + ord)
                else
                    @evaluation_results = @evaluation_results.order("evaluation_results.#{params[:order_by]} #{ord}, evaluation_results.id")
                end
            else
                @evaluation_results = @evaluation_results.order("evaluation_results.#{params[:report]} desc")
            end
            @evaluation_results = @evaluation_results.limit(20)

        else
            params[:report] = nil
            @evaluation_results = @evaluation.active_evaluation_results.
                joins("LEFT JOIN services ON evaluation_results.service_id = services.id")
            if params[:order_by]
                #ord = params[:ord] ? 'ASC' : 'DESC'
                params[:ord] = params[:ord] || 'ASC'
                ord = params[:ord]
                if params[:order_by] == 'id'
                    @evaluation_results = @evaluation_results.order("services.code " + ord)
                elsif params[:order_by] == 'name'
                    @evaluation_results = @evaluation_results.
                        joins("LEFT JOIN service_translations ON evaluation_results.service_id=service_translations.service_id AND service_translations.locale='" + I18n.locale.to_s + "'").
                        order("service_translations.name " + ord)
                elsif params[:order_by] == 'theme'
                    @evaluation_results = @evaluation.active_evaluation_results.
                        joins("LEFT JOIN services ON evaluation_results.service_id = services.id").
                        joins("LEFT JOIN theme_services ON theme_services.service_id = services.id").
                        joins("LEFT JOIN theme_translations ON theme_services.theme_id=theme_translations.theme_id AND theme_translations.locale='" + I18n.locale.to_s + "'").
                        joins("LEFT JOIN themes ON theme_services.theme_id=themes.id").
                        order("themes.orderno " + ord)
                else
                    @evaluation_results = @evaluation_results.order("evaluation_results.#{params[:order_by]} IS NULL, evaluation_results.#{params[:order_by]} #{ord}, evaluation_results.id")
                end
            else
                @evaluation_results = @evaluation_results.order("services.code")
            end
        end
        @evaluation_results = @evaluation_results.where('evaluation_results.service_id is not NULL')

        respond_to do |format|
            format.html #
            format.js #
            format.csv do
                headers["Content-Disposition"] = "attachment;filename=FullReport_#{Date.today.strftime("%b_%d_%Y")}.csv"
                headers["Content-Type"] = "text/csv; charset=ISO-8859-1; header=present"
            end
            format.pdf do
                render :pdf => "full-report", :encoding => 'utf8', layout: 'pdf.html.erb', :orientation => 'Landscape', page_size: 'A3', margin: {top: 10, right: 1, bottom: 10, left: 2}
            end
        end
    end

    def pdf_assets
        pdf_asset = PdfAsset.where(evaluation_id: @evaluation.id, key: params[:key], chart_type: params[:chart_type]).first_or_initialize
        pdf_asset.img_string = params[:img_str]
        pdf_asset.save!
        head :ok
    end


    def expenses
        @evaluation_results = @evaluation.active_evaluation_results.
            joins("LEFT JOIN services ON evaluation_results.service_id = services.id").
            joins("LEFT JOIN theme_services ON theme_services.service_id = services.id").
            joins("LEFT JOIN theme_translations ON theme_services.theme_id=theme_translations.theme_id AND theme_translations.locale='" + I18n.locale.to_s + "'").
            joins("LEFT JOIN themes ON theme_services.theme_id=themes.id")
        if params[:order_by]
            params[:ord] = params[:ord] || 'ASC'
            ord = params[:ord]
            if params[:order_by] == 'id'
                @evaluation_results = @evaluation_results.order("services.code " + ord)
            elsif params[:order_by] == 'theme'
                @evaluation_results = @evaluation_results.order("themes.orderno " + ord)
            else
                @evaluation_results = @evaluation_results.order("evaluation_results.#{params[:order_by]} #{ord}, evaluation_results.id")
            end
        else
            @evaluation_results = @evaluation_results.order('evaluation_results.id, evaluation_results.cloned_index')
        end

        respond_to do |format|
            format.html #
            format.csv do
                headers["Content-Disposition"] = "attachment;filename=expenses_#{Date.today.strftime("%b_%d_%Y")}.csv"
                headers["Content-Type"] = "text/csv; charset=ISO-8859-1"
            end
            format.pdf do
                render :pdf => "expenses", :encoding => 'utf8', layout: 'pdf.html.erb', :orientation => 'Landscape', page_size: 'A4', margin: {top: 10, right: 1, bottom: 10, left: 2}
            end
        end
    end

    def dependences
        @evaluation_results = @evaluation.active_evaluation_results.
            joins("LEFT JOIN services ON evaluation_results.service_id = services.id").
            joins("LEFT JOIN theme_services ON theme_services.service_id = services.id").
            joins("LEFT JOIN theme_translations ON theme_services.theme_id=theme_translations.theme_id AND theme_translations.locale='" + I18n.locale.to_s + "'").
            joins("LEFT JOIN themes ON theme_services.theme_id=themes.id")
        if params[:order_by]
            params[:ord] = params[:ord] || 'ASC'
            ord = params[:ord]
            if params[:order_by] == 'id'
                @evaluation_results = @evaluation_results.order("services.code " + ord)
            elsif params[:order_by] == 'theme'
                @evaluation_results = @evaluation_results.order("themes.orderno " + ord)
            else
                @evaluation_results = @evaluation_results.order("evaluation_results.#{params[:order_by]} #{ord}, evaluation_results.id")
            end
        else
            @evaluation_results = @evaluation_results.order('services.code, evaluation_results.cloned_index')
        end

        g = EvaluationGraph.new @evaluation
        g.draw

        respond_to do |format|
            format.html #
            format.csv do
                headers["Content-Disposition"] = "attachment;filename=dependences_#{Date.today.strftime("%b_%d_%Y")}.csv"
                headers["Content-Type"] = "text/csv; charset=ISO-8859-1"
            end
            format.pdf do
                render :pdf => "dependences", :encoding => 'utf8', layout: 'pdf.html.erb', :orientation => 'Landscape', page_size: 'A4', margin: {top: 10, right: 1, bottom: 10, left: 2}
            end
        end
    end

    def publish
        if current_customer.premium? && @evaluation.can_be_published?
            @evaluation.update_column(:status, Evaluation::STATUSES.index("published"))
            @evaluation.update_column(:published_at, Time.now)
            @evaluation.update_column(:published_by, current_user.id)
        end
        respond_to do |format|
            format.html {redirect_to customer_evaluation_path(current_customer, @evaluation)}
        end
    end


    # POST /evaluations
    # POST /evaluations.json
    def create
        @evaluation = current_customer.customer_evaluations.new(evaluation_params)
        if params['clone'] == 'true'
            @evaluation = @evaluation.clone_last_evaluation
            @evaluation.name = params[:evaluation][:name]
            @evaluation.status = Evaluation::STATUSES.index("draft")
            @evaluation.published_at = nil
        end

        if params[:testing] == 'true'
            @evaluation = Evaluation.sample_evaluation.clone_evaluation
            @evaluation.name = params[:evaluation][:name]
            @evaluation.status = Evaluation::STATUSES.index("draft")
            @evaluation.published_at = nil
            @evaluation.distinguish_type = Evaluation::TYPES.index(:sandbox)
        end

        @evaluation.company_id = current_company.id
        @evaluation.customer_id = current_customer.id
        @evaluation.created_by = current_user.id

        respond_to do |format|
            if @evaluation.save
                @evaluation.create_default_evaluation_services if params['clone'] != 'true'
                format.html {redirect_to customer_evaluation_path(current_customer, @evaluation), notice: I18n.t('evaluations.messages.successfully_created')}
                format.json {render json: @evaluation, status: :created, location: @evaluation}
            else
                format.html {render action: "new"}
                format.json {render json: @evaluation.errors, status: :unprocessable_entity}
            end
        end
    end

    # PATCH/PUT /evaluations/1
    # PATCH/PUT /evaluations/1.json
    def update
        @evaluation.updated_by = current_user.id

        respond_to do |format|
            if @evaluation.update_attributes(evaluation_params)
                format.html {redirect_to customer_evaluation_path(current_customer, @evaluation), notice: I18n.t('evaluations.messages.successfully_updated')}
                format.json {head :no_content}
            else
                format.html {render action: "edit"}
                format.json {render json: @evaluation.errors, status: :unprocessable_entity}
            end
        end
    end

    # DELETE /evaluations/1
    # DELETE /evaluations/1.json
    def destroy
        @evaluation.destroy

        respond_to do |format|
            format.html {redirect_to customer_path(current_customer)}
            format.json {head :no_content}
        end
    end

    private

    def can_show_full_reports_restriction
        unless @evaluation.can_show_full_reports?
            redirect_to(dashboard_customer_evaluation_path(current_customer, @evaluation), :alert => I18n.t('reports.no_access_message'))
            return
        end
    end

    def evaluation_params
        params.require(:evaluation).permit(:name, :customer_id, :company_id)
    end

    def current_customer
        @customer ||= customer_scope.find params[:customer_id]
    end

    def find_evaluation
        @evaluation = current_customer.customer_evaluations.find(params[:id])
    end

    def customer_user_cannot_change_published_evaluation
        if current_company.is_customer? && @evaluation.is_published?
            flash[:alert] = I18n.t('evaluations.form.cannot_change_published_evaluation')
            redirect_to root_path and return
        end
    end

    def check_has_location
        redirect_to(customer_path(current_customer), alert: I18n.t("evaluation_results.add_at_least_one_location")) if current_customer.company_branches.empty?
    end

    def check_no_current_evaluation_exists
        redirect_to customer_path(current_customer) if !params[:testing] && current_customer.has_current_evaluation?
    end

    def check_plan_subscription
        if current_customer.customer_evaluations.not_sandbox.count > 0 && !params[:testing] && !current_customer.premium?
            redirect_back(fallback_location: root_path, alert: I18n.t("upgrade.feature_unavailable"))
        end
    end

    def fetch_not_selected_evaluation_services
        #params[:order] = params[:order] || 'theme'
        params[:left_order] = params[:left_order] || session[:left_service_orderitem]

        check_new_services
        @left_filters = {status: params[:status], search: params[:search], order: params[:left_order], filter: params[:filter], theme: params[:theme]}

        evaluation_services = @evaluation.evaluation_services.joins(:service)
        if @left_filters[:status].present? && @left_filters[:status] == 'deactivated'
            evaluation_services = evaluation_services.deactivated
        else
            evaluation_services = evaluation_services.draft
        end

        if @left_filters[:search].present?
            evaluation_services = evaluation_services.
                joins('INNER JOIN service_translations ON service_translations.service_id = evaluation_services.service_id').
                where('service_translations.locale=?', I18n.locale.to_s).
                where("LOWER(service_translations.name) LIKE :search OR LOWER(services.code) LIKE :search OR LOWER(service_translations.purpose) LIKE :search ", search: "%#{@left_filters[:search].downcase}%")
        end
        if @left_filters[:order] == 'name'
            session[:left_service_orderitem] = 'name'
            evaluation_services = evaluation_services.
                joins('INNER JOIN service_translations ON service_translations.service_id = evaluation_services.service_id').
                where('service_translations.locale=?', I18n.locale.to_s).
                order("service_translations.name, services.position")
        elsif @left_filters[:order] == 'code'
            session[:left_service_orderitem] = 'code'
            evaluation_services = evaluation_services.order('services.code, services.position')
        elsif @left_filters[:order] == 'theme'
            #evaluation_services = evaluation_services.includes(service: :theme_services).order('theme_services.theme_id')
            session[:left_service_orderitem] = 'theme'
            evaluation_services = evaluation_services.joins('INNER JOIN theme_services ON theme_services.service_id=evaluation_services.service_id').
                joins('INNER JOIN theme_translations ON theme_translations.theme_id=theme_services.theme_id').
                includes(service: :theme_services).
                where('theme_translations.locale=?', I18n.locale.to_s).
                order('theme_translations.name, services.position')
        else
            evaluation_services = evaluation_services.order('evaluation_services.position')
        end
        if @left_filters[:theme].present? and @left_filters[:theme].split(',').any?
            evaluation_services = evaluation_services.joins(service: :theme_services).where("theme_services.theme_id IN (#{@left_filters[:theme]})")
        end

        if @left_filters[:filter].present?
            attribute, value = @left_filters[:filter].split(':')

            evaluation_services = case attribute
                                  when 'status'
                                      evaluation_services = evaluation_services.where("evaluation_services.evaluation_id = #{@evaluation.id}").where('evaluation_services.status=:status', status: value)
                                  else
                                      evaluation_services.all
                                  end
        end

        evaluation_services
    end


    def check_new_services
        if @evaluation.is_draft?
            new_added_services = Service.where("id not in (?)", @evaluation.evaluation_services.pluck(:service_id))
            if new_added_services.any?
                new_added_services.each do |s|
                    @evaluation.evaluation_services.build(service_id: s.id, position: s.position, status: EvaluationService::STATUSES.index(:draft))
                end
                @evaluation.save!
            end
        end
    end

    def fetch_evaluation_results
        #params[:order] = params[:order] || 'theme'
        params[:right_order] = params[:right_order] || session[:right_service_orderitem]
        @right_filters = {status: params[:status], search: params[:search], order: params[:right_order], filter: params[:filter], theme: params[:theme]}
        evaluation_results = @evaluation.evaluation_results.joins(service: :evaluation_services).where("evaluation_services.evaluation_id = #{@evaluation.id} AND evaluation_services.cloned_index=evaluation_results.cloned_index")
        #.joins('INNER JOIN services ON services.id = evaluation_results.service_id')

        if @right_filters[:status].present? && @right_filters[:status] == 'ignored'
            evaluation_results = evaluation_results.merge(EvaluationResult.ignored)
        else
            evaluation_results = evaluation_results.merge(EvaluationResult.active)
        end


        if @right_filters[:search].present?
            evaluation_results = evaluation_results.
                joins('INNER JOIN service_translations ON service_translations.service_id = evaluation_results.service_id').
                where('service_translations.locale=?', I18n.locale.to_s).
                where("LOWER(service_translations.name) LIKE :search OR LOWER(services.code) LIKE :search OR LOWER(service_translations.purpose) LIKE :search ", search: "%#{@right_filters[:search].downcase}%")
        end
        if @right_filters[:theme].present? && @right_filters[:theme].split(",").any?
            evaluation_results = evaluation_results.joins(service: :theme_services).where("theme_services.theme_id IN (#{@right_filters[:theme]})")
        end

        if @right_filters[:order] == 'name'
            session[:right_service_orderitem] = 'name'
            evaluation_results = evaluation_results.
                joins('INNER JOIN service_translations ON service_translations.service_id = evaluation_results.service_id').
                where('service_translations.locale=?', I18n.locale.to_s).
                #order("service_translations.name, evaluation_results.cloned_index")
                order("service_translations.name, services.position, evaluation_results.cloned_index")
        elsif @right_filters[:order] == 'code'
            session[:right_service_orderitem] = 'code'
            #evaluation_results = evaluation_results.order('services.code, evaluation_results.cloned_index')
            evaluation_results = evaluation_results.order('services.code, services.position, evaluation_results.cloned_index')
        elsif @right_filters[:order] == 'priority'
            evaluation_results = evaluation_results.order('evaluation_results.assessment_status desc, evaluation_results.cloned_index')
        elsif @right_filters[:order] == 'theme'
            session[:right_service_orderitem] = 'theme'
            #evaluation_results = evaluation_results.includes(service: :theme_services).order('theme_services.theme_id')
            evaluation_results = evaluation_results.joins('INNER JOIN theme_services ON theme_services.service_id=evaluation_results.service_id').
                joins('INNER JOIN theme_translations ON theme_translations.theme_id=theme_services.theme_id').
                includes(service: :theme_services).
                where('theme_translations.locale=?', I18n.locale.to_s).
                order('theme_translations.name, services.position')
        else
            #evaluation_results = evaluation_results.includes(service: :theme_services).order('theme_services.theme_id')
            evaluation_results = evaluation_results.joins('INNER JOIN theme_services ON theme_services.service_id=evaluation_results.service_id').
                joins('INNER JOIN theme_translations ON theme_translations.theme_id=theme_services.theme_id').
                includes(service: :theme_services).
                where('theme_translations.locale=?', I18n.locale.to_s).
                order('theme_translations.name, services.position')
        end
        session[:right_service_query] = evaluation_results.to_sql
        evaluation_results
    end

end
