class WorkProcessesController < ApplicationController

  before_action :admin_required!

  # GET /work_processes
  # GET /work_processes.json
  def index
    @work_processes = WorkProcess.all
    @work_processes = WorkProcess.includes(:translations).with_locales(I18n.locale).order('work_process_translations.name')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @work_processes }
    end
  end

  # GET /work_processes/1
  # GET /work_processes/1.json
  def show
  @work_process = WorkProcess.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @work_process }
    end
  end


  # GET /work_processes/new
  # GET /work_processes/new.json
  def new
  @work_process = WorkProcess.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work_process }
    end
  end

  # GET /work_processes/1/edit
  def edit
    @work_process = WorkProcess.find(params[:id])
  end

  # POST /work_processes
  # POST /work_processes.json
  def create
    @work_process = WorkProcess.new(work_process_params)
    respond_to do |format|
      if @work_process.save
        format.html { redirect_to work_processes_path, notice: I18n.t('commons.successfully_created') }
        format.json { render json: @work_process, status: :created, location: @work_process }
      else
        format.html { render action: "new" }
        format.json { render json: @work_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_processes/1
  # PATCH/PUT /work_processes/1.json
  def update
    @work_process = WorkProcess.find(params[:id])

    respond_to do |format|
      if @work_process.update_attributes(work_process_params)
        format.html { redirect_to work_processes_path, notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @work_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_processes/1
  # DELETE /work_processes/1.json
  def destroy
    @work_process = WorkProcess.find(params[:id])
    @work_process.destroy

    respond_to do |format|
      format.html { redirect_to work_processes_path, notice: I18n.t('commons.successfully_deleted') }
      format.js#
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def work_process_params
      params.require(:work_process).permit(:translations_attributes => [:id, :locale, :name])
    end

  protected

    def admin_required!
      current_user.is_admin? or access_denied!
    end
end
