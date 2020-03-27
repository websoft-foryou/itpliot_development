$ ->
  $('#evaluation_redirect_location').on "click", (e) ->
    ask = window.confirm($(this).data('trad'))
    return false unless ask

  $('.disabled-link').on "click", (e) ->
    e.preventDefault()
    return false


  $(".submit_with_loading").submit ->
    $('#loading-overlay').show()

  $("a.go_with_loading").on "click", (e) ->
    $('#loading-overlay').show()

  if $('#evaluation_reports_list').length > 0
    if $('#evaluation_reports_list').attr("data-reports-url")
      $.get($('#evaluation_reports_list').data('reports-url'))

  $('.go_full_link').on "click", (e) ->
    e.stopPropagation()

  $(document).on 'click.bs.collapse.data-api', '[data-toggle=collapse]', (e) ->
    $(document).find('.collapse.in').collapse('hide');

  $('#save_and_go_to_next').on "click", (e) ->
    $('#next_action').val('next')
  
  $('#full_assessment_report_eval').DataTable
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    paging: false
    fixedColumns: {leftColumns: 3}
    searching: false
    order:false

  setTableScrollStyle = ->
      w = $('.dataTables_scrollBody').css('height');
      $('.DTFC_LeftBodyWrapper').css('height', w)
      $('.DTFC_LeftBodyLiner').css('height', '401px')
      $('.DTFC_LeftBodyLiner').css('max-height', '401px')
      $('.dataTables_scrollHead').css('width', '100%')
      $('.dataTables_scrollBody').css('width', '100%')
      $('.dataTables_scrollFoot').css('width', '100%')
      $('.DTFC_LeftFootWrapper').css('top', '0px')
      $('#full_report_eval_column_info').css('display', 'none')

  table = $('#full_report_eval_column').DataTable
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    paging: false
    searching: false
    fixedColumns: {leftColumns: 3}
    order: false
    fnInitComplete: ->
      $('.dataTables_scrollBody').css('overflow', 'hidden scroll')
      $('.dataTables_scrollFoot').css('overflow', 'auto')
      setTimeout setTableScrollStyle, 100
      $('.dataTables_scrollFoot').on 'scroll', (e) ->
          $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft())
  
  $('#employees-tbl').DataTable
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    paging: false
    searching: false
    fixedColumns: {leftColumns: 2}
    
  
  $('#resources_tbl').DataTable
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    paging: false
    searching: false
    # fixedColumns: {leftColumns: 5}
  
  $('#aggregateReports').DataTable
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    paging: false
    searching: false
    fixedColumns: {leftColumns: 2}
  
  $('#fteReports').DataTable
    scrollY: 400
    scrollX: true
    scrollCollapse: true
    paging: false
    searching: false
    fixedColumns: {leftColumns: 5}
    
calcTotalGbReserved = ->
	total_gb_reserved = 0
	$('.js_crud .children:visible .evaluation_result_server_gb_reserved').each () ->
		total_gb_reserved += parseFloat $(this).val()
	$('.evaluation_result_total_gb_reserved').val(total_gb_reserved.toFixed 1)

calcTotalGbUsed = ->
	total_gb_used = 0
	$('.js_crud .children:visible .evaluation_result_server_gb_used').each () ->
		total_gb_used += parseFloat $(this).val()
	$('.evaluation_result_total_gb_used').val(total_gb_used.toFixed 1)

$ ->
  $("#check_all_evaluation_services").change ->
    $("input.check_evaluation_service").prop("checked", $(@).is(":checked"))
    refreshEvaluationServices()

  $("#sortable_list").on 'change', 'input.check_evaluation_service', ->
    refreshEvaluationServices()

  $("#check_all_evaluation_results").change ->
    $("input.check_evaluation_result").prop("checked", $(@).is(":checked"))
    refreshEvaluationResults()

  $("#it_services_list").on 'change', 'input.check_evaluation_result', ->
    refreshEvaluationResults()

  $(".evaluation_result_server_gb_reserved").change () -> 
      calcTotalGbReserved()

  $(".evaluation_result_server_gb_used").change () -> 
      calcTotalGbUsed()

window.refreshEvaluationServices = ->
  values = $("input.check_evaluation_service:checked").map ->
      $(@).val()
    .get().join(',')
    $("#selected_service_ids").val(values)
    return false

window.refreshEvaluationResults = ->
  values = $("input.check_evaluation_result:checked").map ->
      $(@).val()
    .get().join(',')
    $("#selected_results_ids").val(values)
    return false


$ ->
  $	$('#view_chart_btn').click (e) ->
    e.preventDefault()
    $("html, body").animate { scrollTop: $(document).height() }, 600
    return false
