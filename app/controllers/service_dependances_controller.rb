class ServiceDependancesController < ApplicationController



  # POST /service_dependances
  # POST /service_dependances.json
  def create
    @service_dependance = ServiceDependance.new(service_dependance_params)

    respond_to do |format|
      if @service_dependance.save
        format.html { redirect_to @service_dependance, notice: 'Service dependance was successfully created.' }
        format.json { render json: @service_dependance, status: :created, location: @service_dependance }
      else
        format.html { render action: "new" }
        format.json { render json: @service_dependance.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /service_dependances/1
  # DELETE /service_dependances/1.json
  def destroy
    @service_dependance = ServiceDependance.find(params[:id])
    @service_dependance.destroy

    respond_to do |format|
      format.html { redirect_to service_dependances_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def service_dependance_params
      params.require(:service_dependance).permit(:depending_id, :service_id)
    end
end
