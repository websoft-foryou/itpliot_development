class CompanyUsersController < ApplicationController
  #before_action :admin_required!

  # POST /companies
  # POST /companies.json
  def create
    @company_user = current_company.company_users.new(company_params)

    respond_to do |format|
      if @company_user.save
        format.html { redirect_back(fallback_location: root_path, notice: I18n.t('company_users.user_sucessfully_added')) }
        format.json { render json: @company_user, status: :created, location: @company_user }
        format.js#
      else
        format.html {
          flash[:error] = "must select user"
          redirect_back(fallback_location: root_path)
        }
        format.json { render json: @company_user.errors, status: :unprocessable_entity }
        format.js#
      end
    end
  end


  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company_user = current_company.all_company_users.find(params[:id])
    @company_user.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { head :no_content }
      format.js#
    end
  end

  private

    def current_company
      @company ||= Company.find params[:company_id]
    end

    def company_params
      params.require(:company_user).permit(:user_id, :company_branch_id)
    end

  protected

    def admin_required!
      current_user.is_admin? or access_denied!
    end
end
