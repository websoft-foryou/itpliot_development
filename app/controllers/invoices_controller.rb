class InvoicesController < ApplicationController
  def index
    if params[:dsp_id]
      @invoices = Invoice.where("company_id IN (?)", customer_scope.where(parent_id: current_company.id).pluck(:id)).select{|i| i.plan}
    else
      @invoices = Invoice.where("company_id IN (?)", partner_scope.where(parent_id: current_company.id).pluck(:id)).order("id").select{|i| i.plan}
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @invoices }
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      if @invoice.update_attributes(invoice_params)
        format.html { redirect_to action: 'index', notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
      end
    end

  end

  def set_internal_no
    @invoice = Invoice.find(params[:invoice_id])

    @invoice.update_attributes(internal_no: params[:internal_no])
    head :ok
  end

  def set_status
    @invoice = Invoice.find(params[:invoice_id])

    @invoice.update_attributes(status: params[:status])
    head :ok
  end

  private
    def invoice_params
      params.require(:invoice).permit(:internal_no, :status)
    end

end
