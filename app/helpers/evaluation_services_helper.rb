module EvaluationServicesHelper
  def evaluation_services_filters options={}
    a = []
    a << [t('commons.themes'), Theme.all.map { |a| [a.name, "theme:#{a.id}"] }]
    a << [t('left_menu.industries'), Industry.all.map { |a| [a.name, "industry:#{a.id}"] }]
    a
  end

  def result_status_info(evaluation_result, text = false)
    status = EvaluationResult::ASSESSMENT_STATUSES[evaluation_result.assessment_status].to_s
    out = '<div class="assessment_status_info">'
      out += '<div class="status_img ' + status + '"></div>'
      out += '<span>' + t('evaluation_results.form.labels.' + status ) + '</span>' if text
    out += '</div>'
    out.html_safe
  end

  def result_status_pdf_image(evaluation_result)
    status = EvaluationResult::ASSESSMENT_STATUSES[evaluation_result.assessment_status].to_s
    case status
    when 'urgent'
      'icons/btn_red.png'
    when 'medium'
      'icons/btn_yellow.png'
    when 'no_action'
      'icons/btn_green.png'
    else
      ''
    end
  end

  def display_result_service_status(evaluation_result)
    status = evaluation_result.evaluation_service.status_name
    out = ""
    out += "<div class='btn-group' style='min-width:88px;'>"
      out += "<div class='btn btn-default btn-xs disabled #{'btn-success' if status == :active}'>"
        out += "<i class='fa fa-check' aria-hidden='true'></i>"
      out += "</div>"
      out += "<div class='btn btn-default btn-xs disabled #{'btn-info' if status == :ignored}'>"
        out += "<i class='fa fa-minus' aria-hidden='true'></i>"
      out += "</div>"
      out += "<div class='btn btn-default btn-xs disabled #{'btn-danger' if status == :deactivated}'>"
        out += "<i class='fa fa-close' aria-hidden='true'></i>"
      out += "</div>"
      out += "<div class='btn btn-default btn-xs disabled #{'btn-custom-draft' if status == :draft}'>"
        out += "<i class='fa fa-cog' aria-hidden='true'></i>"
      out += "</div>"
    out += "</div>"
    out.html_safe
  end

  def service_not_active_label(evaluation_result)
    service_status = evaluation_result.evaluation_service.status_name if evaluation_result.evaluation_service
    out = case service_status
    when :ignored
      '<span class="label label-primary">'+t('commons.ignored')+'</span>'.html_safe
    when :deactivated
      '<span class="label label-danger">'+t('commons.deactivated')+'</span>'.html_safe
    when :draft
      '<span class="label label-default">'+t('commons.draft')+'</span>'.html_safe
    else
      ''
    end
    out.html_safe
  end

end
