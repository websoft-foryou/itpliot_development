class NewServiceRequestsController < ApplicationController
    
    def index
        @service_request = ServiceRequest.new
        
        #respond_to do |format|
        #    format.html
        #    format.json
        #end
    end
    
    def create
        input_values = params[:service_request]
        @service_request = ServiceRequest.new
        @service_request.service_name = input_values[:service_name]
        @service_request.description = input_values[:description]
        @service_request.prod_example = input_values[:prod_example]
        @service_request.company_name = input_values[:company_name]
        @service_request.contact = input_values[:contact]
        @service_request.email = input_values[:email]
        @service_request.telephone = input_values[:telephone]
        @service_request.reason = input_values[:reason]

        #respond_to do |format|
        #    format.html
        #    format.json
        #    format.js {render inline: "location.reload();" }
        #end
        if @service_request.save
            flash[:notice] = I18n.t("it_service_request.send_success")
            ServiceRequestMailer.service_request(input_values[:service_name], input_values[:description], input_values[:prod_example], input_values[:company_name],
                                                 input_values[:contact], input_values[:email], input_values[:telephone], input_values[:reason]).deliver
        else
            flash[:notice] = I18n.t("it_service_request.send_failure")
        end
        
        redirect_to action: 'index'
        
    end

end
