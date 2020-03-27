$ ->
  $('.toggle_column').on "click", (e) ->
    cls = $(this).parent().attr('class').split(' ')[0]
    $('.'+cls).toggleClass('minimized')

    $('div.dataTables_scrollBody>table').dataTable().fnAdjustColumnSizing()

    if $(this).parent().hasClass('minimized')
      $(this).html('&raquo;')
    else
      $(this).html('&laquo;')

window.saveGraphResource = (cid,eid,key,chart_type,img_str) ->
  $.ajax
      url: '/customers/'+cid+'/evaluations/'+eid+'/pdf_assets'
      data: { key: key, chart_type: chart_type, img_str: img_str }
      type: "POST"
      # success: (data, textStatus, jqXHR) ->
      #   alert "Successful AJAX call: #{data}"
      error: (jqXHR, textStatus, errorThrown) ->
        alert "AJAX Error: #{textStatus}"

