$ ->
  $('#btn-download').on "click", (e) ->
    e.preventDefault()
    $('#myModal').modal('show')

  $('#btn-yes').on "click", (e) ->
    $('#myModal').modal('hide')
    $(this).closest("form").submit()

  $('#company_information').on "change", (e) ->
    all_checkboxes_unchecked = !$('#company_information').prop("checked") && !$('#service_sets').prop("checked") && !$('#invoices').prop("checked") && !$('#users').prop("checked") && !$('#company_members').prop("checked")
    $('#btn-download').attr('disabled', all_checkboxes_unchecked)

  $('#service_sets').on "change", (e) ->
    all_checkboxes_unchecked = !$('#company_information').prop("checked") && !$('#service_sets').prop("checked") && !$('#invoices').prop("checked") && !$('#users').prop("checked") && !$('#company_members').prop("checked")
    $('#btn-download').attr('disabled', all_checkboxes_unchecked)

  $('#invoices').on "change", (e) ->
    all_checkboxes_unchecked = !$('#company_information').prop("checked") && !$('#service_sets').prop("checked") && !$('#invoices').prop("checked") && !$('#users').prop("checked") && !$('#company_members').prop("checked")
    $('#btn-download').attr('disabled', all_checkboxes_unchecked)

  $('#users').on "change", (e) ->
    all_checkboxes_unchecked = !$('#company_information').prop("checked") && !$('#service_sets').prop("checked") && !$('#invoices').prop("checked") && !$('#users').prop("checked") && !$('#company_members').prop("checked")
    $('#btn-download').attr('disabled', all_checkboxes_unchecked)

  $('#company_members').on "change", (e) ->
    all_checkboxes_unchecked = !$('#company_information').prop("checked") && !$('#service_sets').prop("checked") && !$('#invoices').prop("checked") && !$('#users').prop("checked") && !$('#company_members').prop("checked")
    $('#btn-download').attr('disabled', all_checkboxes_unchecked)

#  $('#password').on "keydown", (e) ->
#    if e.key == 'Enter'
#      $('#btn-yes').click()