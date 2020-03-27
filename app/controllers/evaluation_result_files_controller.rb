class EvaluationResultFilesController < ApplicationController

  before_action :fetch_evaluation_result

  def show
    @evaluation_result_file = @evaluation_result.evaluation_result_files.find(params[:id])
    send_file @evaluation_result_file.document.path, :type => @evaluation_result_file.document_content_type, :disposition => 'inline'
  end

  def create
      @evaluation_result_file = @evaluation_result.evaluation_result_files.create files_params

      respond_to do |format|
          format.js
      end
  end

  def destroy
      @evaluation_result_file = @evaluation_result.evaluation_result_files.find(params[:id])
      @evaluation_result_file.destroy
      respond_to do |format|
          format.js#
      end
  end

  private

    def current_evaluation
        @evaluation ||= Evaluation.find params[:evaluation_id]
      end

      def current_customer
        @customer ||= customer_scope.find params[:customer_id]
      end


    def files_params
        params.require(:evaluation_result_file).permit :asset
    end

    def fetch_evaluation_result
      @evaluation_result = current_evaluation.evaluation_results.find(params[:evaluation_result_id])
    end


end
