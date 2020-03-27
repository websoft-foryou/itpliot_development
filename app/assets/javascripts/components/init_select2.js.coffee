$ ->
	$(".single_select2").each -> 
		window.initSelect2 $(@)


window.initSelect2 = (el) ->
	options = {}
	if el.attr("maximumselectionsize")
		options["maximumSelectionSize"] = el.attr("maximumselectionsize")
	if el.attr("data-placeholder")
		options["placeholder"] = el.attr("data-placeholder")
	if el.attr("data-init-value") && el.attr("data-init-value").length > 0
		options["initSelection"] = (el, callback) -> 
			callback(el.data("init-value"))
	if el.attr("data-url")
		options["minimumInputLength"] = 1
		options["ajax"] = 
			url: el.attr("data-url")
			dataType: "json"
			data: (term, page) ->
				search: term
			results: (data, page) ->
				results: data
		options["formatResult"] = profileResult
		options["formatSelection"] = profileFormatSelection
		options["dropdownCssClass"] = "bigdrop"
		options["escapeMarkup"] = (m) -> m
		options["formatNoMatches"] = -> el.data("no-results")
		options["formatInputTooShort"] = -> el.data("min-length-required")
		options["formatSearching"] = -> el.data("searching")
		options["multiple"] = true if el.data("multiple")
		options["dropdownCssClass"] = "bigdrop"

	el.select2(options)

profileResult = (profile) ->
	markup = "<div class='media' style='border-bottom: 1px solid lightgrey;'>"
	# markup += "<span class='pull-left thumb-large'><img src='#{profile.logo_url}' alt='logo_image_#{profile.id}'/></span>"
	markup += "<div class='media-body'><div class='title'>#{profile.name}</div><div class='description'>#{profile.email}</div></div>"
	markup += "</div>"
	markup

profileFormatSelection = (profile) ->
	profile.name