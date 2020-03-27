$ ->
  $('#complete_location_copy').on "click", (e) ->
    e.preventDefault()
    $('#addresspicker_map').val($('#clone_address').html())
    $('#pick_address').val($('#clone_address').html())
    $('#pick_country').val($('#clone_country').html())
    $('#pick_city').val($('#clone_city').html())
    $('#postal_code').val($('#clone_zip').html())
    return false