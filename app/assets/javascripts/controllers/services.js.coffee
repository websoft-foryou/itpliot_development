$ ->
  $('#service_form_submit').click ->
    no_error = true
    $('.remote_jsvalid').each (obj) ->
      if $(this).val() == ''
        $(this).wrap("<span class='error'></span>")
        $('label[for="'+$(this).attr('id')+'"]').wrap("<span class='error'></span>")
        no_error = false
      else
        $(this).unwrap() if $(this).parent().hasClass('error')
        if $('label[for="'+$(this).attr('id')+'"]').parent().hasClass('error')
          $('label[for="'+$(this).attr('id')+'"]').unwrap()
    return false unless no_error