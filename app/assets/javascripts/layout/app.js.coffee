$ ->

	if document.getElementById('image_gallery') != null
		unless document.getElementById('image_gallery').classList.contains("edit")
			document.getElementById('image_gallery').onclick = (event) ->
				event = event or window.event
				console.log event.target.nodeName
				return false if event.target.nodeName == "I"
				return false if event.target.nodeName == "INPUT"
				target = event.target or event.srcElement
				link = if target.src then target.parentNode else target
				options =
					index: link
					event: event
				links = @getElementsByClassName('ablock')
				blueimp.Gallery links, options
				return

	$(".owl-carousel").owlCarousel
		items: 1
		nav: true
		pagination: false
		scrollPerPage: true
		navText : ["",""]

	# $("input[type='file'][data-preview-image=true]").each ->
	# 	window.previewImageUpload $(@)

	$(window).scroll ->
		if $(this).scrollTop() > 600
			$('#scrollup').fadeIn()
		else
			$('#scrollup').fadeOut()

	$('#scrollup').click ->
		$("html, body").animate { scrollTop: 0 }, 600
		return false

	$(".submit_on_select").on "change", (e) ->
		e.preventDefault()
		$(this).closest("form").submit()

	$(".submit_on_click").on "click", (e) ->
		e.preventDefault()
		$(this).closest("form").submit()

	$(".observe").observe ->
		$(@).closest("form").submit()


	$("[data-toggle=tooltip]").tooltip(container: 'body')

	$(".toggle_datepicker").each ->
		window.initDatepicker( $(@) )

	$("#reload_opt_tree #cu_options_tree").on "change", (e) ->
    $("[id^=user_company_users_attributes_]").remove()

    if ($(this).val() && $(this).val().length > 0)
      $(this).val().forEach (v, i) ->
        [cid, cbid, id] = v.split("#")
        $("form").append("<input type='hidden' class='user_company_users_attributes' id='user_company_users_attributes_#{i}_company_id' name='user[company_users_attributes][#{i}][company_id]'></input>")
        $("#user_company_users_attributes_#{i}_company_id").val(cid)
        $("form").append("<input type='hidden' class='user_company_users_attributes' id='user_company_users_attributes_#{i}_company_branch_id' name='user[company_users_attributes][#{i}][company_branch_id]'></input>")
        $("#user_company_users_attributes_#{i}_company_branch_id").val(cbid)
        $("form").append("<input type='hidden' class='user_company_users_attributes' id='user_company_users_attributes_#{i}_id' name='user[company_users_attributes][#{i}][id]'></input>")
        $("#user_company_users_attributes_#{i}_id").val(id)


	$("#reload_opt_tree #cu_options_tree").trigger('change')

	setTimeout (-> $("#flash_messages").slideUp 1000 ), 5000

	$(".js_crud").each ->
		window.applyJsCrud $(@)

window.onload = ->
	if $('#select_evaluation_js_reports').length > 0
		$('#select_evaluation_js_reports').submit()
		return

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

calcTotalGbInfo = ->
	calcTotalGbReserved()
	calcTotalGbUsed()

window.onChangeGbInfo = () ->
	calcTotalGbInfo()

	$(".evaluation_result_server_gb_reserved").change () -> 
		calcTotalGbInfo()

	$(".evaluation_result_server_gb_used").change () -> 
		calcTotalGbInfo()

window.applyJsCrud = (el) ->
	$(el).crud
		property: el.data("property")
		new_button_text: el.data("new-button-text")
		item_class: ".children"
		new_button_container_class: ".new_children"
		max_children: el.data("max-children")
		onChange: window.onChangeGbInfo

window.flash_notice = (message) ->
	$("#flash_messages").hide().html("<div id='flash_success' class='alert alert-success'><i class='fa fa-check fa-lg'></i> <span>#{message}</span></div>")
	$("#flash_messages").slideDown("slow")
	setTimeout (-> $("#flash_messages").slideUp 1000 ), 5000

window.previewImageUpload = (input) ->
	$(document).on "change", input, (event) ->

		$input = $(event.target)
		file = $input[0].files[0]
		return unless file?
		imageType = /image.*/

		if !file.type.match imageType
			alert "This type of file cannot be uploaded"
			return

		if $input.data("target")?
			img = $ $input.data("target")
		else
			img = $input.siblings("img").eq 0
		img.file = file;
		reader = new FileReader()
		reader.onload = (e) ->
			img.attr "src", e.target.result

		reader.readAsDataURL file


window.initDatepicker = (el) ->

	clearBtn = if el.data("clear-btn") then true else false

	now = new Date()

	common_date = {
		format: "dd-mm-yyyy"
		clearBtn: clearBtn
		autoclose: true
		endDate: '01-01-3000'
	}
	if el.data("min-date")
		if el.data("min-date") == "now"
			common_date["startDate"] = now

	if el.data("max-date")
		if el.data("max-date") == "now"
			common_date["endDate"] = now

	if el.data("interval")

		# ---------
		start_date_container = el
		end_date_container = el.closest(".interval_container").find( el.data("interval") )

		start_date_container.datepicker( common_date )
		end_date_container.datepicker( common_date )

		start_date_container.on('changeDate', (ev) ->
			start_date = start_date_container.datepicker('getDate')
			end_date = end_date_container.datepicker('getDate')
			if !isNaN(ev.date) && (isNaN(end_date.valueOf()) || start_date.valueOf() > end_date.valueOf())
				end_date_container.datepicker('setDate', start_date)

			if !isNaN(ev.date)
				end_date_container.datepicker('setStartDate', start_date)
				start_date_container.datepicker("hide");
				end_date_container.datepicker("show")
		)

		end_date_container.on('changeDate', (ev) ->
			start_date = start_date_container.datepicker('getDate')
			end_date = end_date_container.datepicker('getDate')
			if !isNaN(ev.date) && (isNaN(start_date.valueOf()) || end_date.valueOf() < start_date.valueOf())
				start_date_container.datepicker('setDate', end_date);

			if !isNaN(ev.date)
				end_date_container.datepicker("hide")
		)

	else
		date = el.datepicker( common_date )

		if el.data("submit-on-select")
			date.on "changeDate", ->
				el.closest("form").submit()
