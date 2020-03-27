$ ->

  $('a[href*="#"]').not('[href="#"]').not('[href="#0"]').click (event) ->
    if location.pathname.replace(/^\//, '') == @pathname.replace(/^\//, '') and location.hostname == @hostname
      target = $(@hash)
      target = if target.length then target else $('[name=' + @hash.slice(1) + ']')
      if target.length
        event.preventDefault()
        $('html, body').animate { scrollTop: target.offset().top }, 1000, ->
          $target = $(target)
          $target.focus()
          if $target.is(':focus')
            return false
          else
            $target.attr 'tabindex', '-1'
            $target.focus()
          return
      return

  offset = 300
  offset_opacity = 1200
  scroll_top_duration = 700
  $back_to_top = $('#gotop_btn')
  $(window).scroll ->
    if $(this).scrollTop() > offset then $back_to_top.addClass('cd-is-visible') else $back_to_top.removeClass('cd-is-visible cd-fade-out')
    if $(this).scrollTop() > offset_opacity
      $back_to_top.addClass 'cd-fade-out'
    return

  $('.nav-tabs:not(.nav-tabs-presentation) a:not(.default)').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    $(this).tab 'show'
    return
