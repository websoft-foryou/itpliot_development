$ ->

  $(".portlet").each ->
    window.applySorting $(@)

window.applySorting = (el) ->
  el.sortable(
    cursor: 'move', items: '.portlet-item',
    opacity: 0.8, helper: 'original', handle: ".portlet-handler", revert: true
    placeholder: 'sortable-box-placeholder', tolerance: 'pointer'
    start: (e, ui) ->
      ui.placeholder.height ui.helper.outerHeight()
    update: (event, ui) ->
      if $(this).attr("data-update-sort-url")
        $.post($(this).data('update-sort-url'), $(this).sortable('serialize'))
        $('#sortable_list .placeholder_position').map((index) ->
          $("#"+@id).html(index + 1)
        ).get()
  )
  el.disableSelection()
