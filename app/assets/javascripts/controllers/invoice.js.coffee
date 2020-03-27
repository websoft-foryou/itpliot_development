$ ->
  $('[name="invoice[internal_no]"]').on "keydown", (e) ->
    if e.key == 'Enter'
      invoice_id = $(this).data('invoice_id')
      $.ajax
        url: '/invoices/' + invoice_id + '/set_internal_no'
        type: 'PUT'
        data: { internal_no: $(this).val() }
        success: (data) ->
          #alert('Load was performed.')
      $(this).blur()

  $('[name="invoice[status]"]').on "change", (e) ->
    invoice_id = $(this).data('invoice-id')
    $.ajax
      url: '/invoices/' + invoice_id + '/set_status'
      type: 'PUT'
      data: { status: $(this).val() }
      success: (data) ->
        #alert('Load was performed.')
