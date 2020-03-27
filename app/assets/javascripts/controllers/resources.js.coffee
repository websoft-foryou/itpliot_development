$ ->
  if $(".resource_activity_graph").length
    $(".resource_activity_graph").each ->
      window.drawPieResource $(@)

  $('#employees-tbl').on "click", '.manage_edit_employee', (e) ->
    e.preventDefault()
    employee_id = $(@).data("employee-id")
    $('#editable-wrapper_' + employee_id).toggleClass("active")

  $('#employees-tbl').on "click", '.btn-order-down', (e) ->
    console.log('btn-order-down clicked', $(this).data('employee-id'), $(this).data('customer-id'), $(this).data('evaluation-id'))
    $.ajax
      method: 'put'
      url: '/customers/'+$(this).data('customer-id')+'/employees/'+$(this).data('employee-id')+'/change_order?evaluation_id='+$(this).data('evaluation-id')+'&type=down'

  $('#employees-tbl').on "click", '.btn-order-up', (e) ->
    console.log('btn-order-up clicked', $(this).data('employee-id'), $(this).data('customer-id'), $(this).data('evaluation-id'))
    $.ajax
      method: 'put'
      url: '/customers/'+$(this).data('customer-id')+'/employees/'+$(this).data('employee-id')+'/change_order?evaluation_id='+$(this).data('evaluation-id')+'&type=up'


  $('.nav-tab-buttons a[data-toggle="tab"]').on 'click', (e) ->
    $('.nav-tab-buttons .btn').removeClass('btn-info')
    $(this).find('.btn').addClass('btn-info')

    $("[id^=progress_tab_]").removeClass("active")
    switch $(this).attr("href")
      when "#tab_employees"
        $("#progress_tab_employees").addClass("active")
      when "#tab_resources"
        $("#progress_tab_employees").addClass("active")
        $("#progress_tab_resources").addClass("active")
      when "#tab_aggregated"
        $("#progress_tab_employees").addClass("active")
        $("#progress_tab_resources").addClass("active")
        $("#progress_tab_aggregated").addClass("active")
      when "#tab_fte"
        $("#progress_tab_employees").addClass("active")
        $("#progress_tab_resources").addClass("active")
        $("#progress_tab_aggregated").addClass("active")
        $("#progress_tab_fte").addClass("active")


  $(".resource_edit_employee").click ->
    employee_id = $(@).data("employee-id")
    active = $(@).hasClass("active")
    $(@).toggleClass("active")
    if active
      $(".full-view.employee_#{employee_id}").hide()
      $(".small-view.employee_#{employee_id}").show()
    else
      $(".full-view.employee_#{employee_id}").show()
      $(".small-view.employee_#{employee_id}").hide()
    false

window.drawPieResource = (el) ->
    colors = [
      '#56E2CF'
      '#56AEE2'
      '#5668E2'
      '#8A56E2'
      '#CF56E2'
      '#E256AE'
      '#E25668'
      '#E22F05'
      '#E28203'
      '#E2B869'
      '#E2D011'
      '#ACE232'
    ]
    pieoptions =
      legend: display: false
      responsive: true
      animation:
        onComplete: () ->
          saveGraphResource(el.data('customer-id'), el.data('evaluation-id'), "employee_graph_#{el.data('employee-id')}", "pie", el.get(0).toDataURL('image/jpeg'));

    id = el.attr('id')
    labels = el.data('labels')
    graphdataset = el.data('graphdataset')
    pieChartData =
      labels: labels
      datasets: [ {
        data: graphdataset
        backgroundColor: colors
      } ]
    new Chart(id,
      type: 'pie'
      data: pieChartData
      options: pieoptions)
  

