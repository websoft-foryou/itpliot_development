module EvaluationsHelper

  def select_service_options_active(evaluation)
    completed = evaluation.evaluation_results.pluck(:service_id)
    service_options_active = evaluation.evaluation_services.active
    service_options_active = service_options_active.where('evaluation_services.service_id NOT IN (?)', completed) if completed.any?
    service_options_active = service_options_active.order(:position)
                            .includes(:service)
                            .map{|a| ["#{a.service.code} - #{a.service.name}", a.service_id]}
  end

  def select_service_options_ignored(evaluation)
    completed = evaluation.evaluation_results.pluck(:service_id)
    service_options_ignored = evaluation.evaluation_services.ignored
    service_options_ignored = service_options_ignored.where('evaluation_services.service_id NOT IN (?)', completed) if completed.any?
    service_options_ignored = service_options_ignored.order(:position)
                            .includes(:service)
                            .map{|a| ["#{a.service.code} - #{a.service.name}", a.service_id]}
  end

  def yes_no_value(v)
    v ? t('commons._yes') : t('commons._no')
  end

  def service_options_grouped(evaluation,current_option = nil)
    service_options_active = select_service_options_active(evaluation)
    service_options_active << current_option if current_option
    service_options_ignored = select_service_options_ignored(evaluation)
    service_options_grouped = [[t('industry_fields.available_services'), service_options_active],[t('industry_fields.ignored_services'), service_options_ignored]]
  end

  def full_assessment_report_actions(customer_id, evaluation_id, order_by)
    content_tag( :span, {class: "up_down"} ) do
      link_to( full_assessment_report_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'asc'), class: "up") do
        content_tag(:div, "", class: "sort_ic_up")
      end +
      link_to( full_assessment_report_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'desc')) do
        content_tag(:div, "", class: "sort_ic_down")
      end
    end.html_safe
  end

  def expense_report_actions(customer_id, evaluation_id, order_by)
    content_tag( :span, {class: "up_down"} ) do
      link_to( expenses_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'asc'), class: "up") do
        content_tag(:div, "", class: "sort_ic_up")
      end +
      link_to( expenses_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'desc')) do
        content_tag(:div, "", class: "sort_ic_down")
      end
    end.html_safe
  end

  def dependence_report_actions(customer_id, evaluation_id, order_by)
    content_tag( :span, {class: "up_down"} ) do
      link_to( dependences_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'asc'), class: "up") do
        content_tag(:div, "", class: "sort_ic_up")
      end +
          link_to( dependences_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'desc')) do
            content_tag(:div, "", class: "sort_ic_down")
          end
    end.html_safe
  end

  def full_report_actions(customer_id, evaluation_id, order_by, report)
    content_tag( :span, {class: "up_down"} ) do
      link_to( full_report_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'asc', report: report), class: "up") do
        content_tag(:div, "", class: "sort_ic_up")
      end +
      link_to( full_report_customer_evaluation_path(customer_id, evaluation_id, order_by: order_by, ord: 'desc', report: report)) do
        content_tag(:div, "", class: "sort_ic_down")
      end
    end.html_safe
  end

  def employee_activity(evaluation,employee_id)
    res = employees_results_activity(evaluation.employee_evaluation_results.where(employee_id: employee_id))
    res[employee_id] || {"e"=>0, "t"=>0, "o"=>0, "v"=>0, "i"=>0, "c"=>0, "a"=>0, "m"=>0, "u"=>0, "l1"=>0, "l2"=>0, "l3"=>0}
  end

  def employees_results_activity(results)
    activities = {}
    start = {}
    EmployeeEvaluationResult::ACTIVITY_TYPES.keys.each{|k| start[k] = 0}
    results.each do |res|
      tmp = activities[res.employee_id] || start
      EmployeeEvaluationResult::ACTIVITY_TYPES.each do |k,v|
        tmp[k] = tmp[k] + 1 if res.send(v)
      end
      activities[res.employee_id] = tmp
    end
    activities
  end


end
