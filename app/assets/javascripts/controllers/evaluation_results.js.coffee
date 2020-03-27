$ ->
  $('#toggle_select_los').change ->
    if @checked
      $('#evaluation_result_evaluation_result_company_branches option').attr('selected', true).parent().trigger('change')
    else
      $('#evaluation_result_evaluation_result_company_branches option').attr('selected', false).parent().trigger('change')

  $('#evaluation_result_result_depending_services, #evaluation_result_result_dependant_services').select2 formatSelection: formatServiceSelect

formatServiceSelect = (service) ->
  service.text.split(' ')[0]



$ ->
  if $("#link_container").length
    new LinkCrud()

class LinkCrud
  constructor: ->
    $("#new_link").on "click", @generateNewLinkInput
    $("#link_container").on "click", ".delete_link", @deleteLinkContainer
    $("#link_container").on "blur", ".link", @validateLink

  generateNewLinkInput: ->
    $new_link_html = $('<div class="form-group link"><div class="col-xs-10"><span><input class="form-control" id="evaluation_result_links_" name="links[]" type="text" value="" data-validate="true"></span></div><div class="col-xs-2 text-center"><a href="#" class="btn btn-link delete_link"><span class="text-danger"><i class="fa fa-trash-o"></i></span></a></div></div>')
    $("#link_container").append $new_link_html
    false

  deleteLinkContainer: ->
    $(@).closest(".link").remove()
    false

  validateLink: ->
    reg = /^(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i
    el = $(@).closest(".link").find('span').first()
    val = $(@).closest(".link").find('input').val()
    if reg.test(val)
      el.removeClass('error')
    else
      el.addClass('error')
      el.focus()
    return
