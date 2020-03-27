$ ->

	$('#toggle_deactivated').click (e) ->
		if $('#services_status').val() == 'draft'
			$('#services_status').val('deactivated')
		else
			$('#services_status').val('draft')
		e.preventDefault()
		$(this).closest("form").submit()

	$('#toggle_active').click (e) ->
    $('#results_status').val('active')
    e.preventDefault()
    $(this).closest("form").submit()

	$('#toggle_ignored').click (e) ->
    $('#results_status').val('ignored')
    e.preventDefault()
    $(this).closest("form").submit()

	$('#toggle_cloned').click (e) ->
    $('#results_status').val('cloned')
    e.preventDefault()
    $(this).closest("form").submit()

	#select service popup
	if $('#mark_ignored').length > 0 && $('#mark_deactivated').length > 0
		mark_ignored = JSON.parse($('#mark_ignored').html())
		mark_deactivated = JSON.parse($('#mark_deactivated').html())

	$('#ss_industry').on "change", (e) ->
		trad_avaliable = $(this).data('available') ? 'Available Services in this Data-Set'
		trad_ignored = $(this).data('ignored') ? 'Ignored Services in this Data-Set'
		$.ajax
			url: '/industries/'+$(this).val()+'/eval_services_options'
			dataType: 'json'
			success: (data) ->
				active = ''
				ignored = ''
				$(data).each (index, el) ->
					return if (mark_deactivated != null && typeof(mark_deactivated) != 'undefined' && ($.inArray(el.id, mark_deactivated) != -1))
					s = "<option value='"+el.id+"'>" + el.code + " - " + el.name + "</option>"
					if mark_ignored != null && typeof(mark_ignored) != 'undefined' && ($.inArray(el.id, mark_ignored) != -1)
						ignored += s
					else
						active += s
				opt = '<optgroup label="'+trad_avaliable+'">'+active+'</optgroup>' unless active == ''
				opt = opt + '<optgroup label="'+trad_ignored+'">'+ignored+'</optgroup>' unless ignored == ''
				$('#ss_industry_opt').html(opt)
				$("#ss_industry_opt").select2()
				return
			error: (jq,status,data) ->
				alert(data)
				return

	$('#ss_theme').on "change", (e) ->
		trad_avaliable = $(this).data('available') ? 'Available Services in this Data-Set'
		trad_ignored = $(this).data('ignored') ? 'Ignored Services in this Data-Set'
		$.ajax
			url: '/themes/'+$(this).val()+'/eval_services_options'
			dataType: 'json'
			success: (data) ->
				active = ''
				ignored = ''
				$(data).each (index, el) ->
					return if (mark_deactivated != null && typeof(mark_deactivated) != 'undefined' && ($.inArray(el.id, mark_deactivated) != -1))
					s = "<option value='"+el.id+"'>" + el.code + " - " + el.name + "</option>"
					if mark_ignored != null && typeof(mark_ignored) != 'undefined' && ($.inArray(el.id, mark_ignored) != -1)
						ignored += s
					else
						active += s
				opt = '<optgroup label="'+trad_avaliable+'">'+active+'</optgroup>' unless active == ''
				opt = opt + '<optgroup label="'+trad_ignored+'">'+ignored+'</optgroup>' unless ignored == ''
				$('#ss_theme_opt').html(opt)
				$("#ss_theme_opt").select2()
				return
			error: (jq,status,data) ->
				alert(data)
				return

	if $('#ss_industry').length > 0
		$('#ss_industry').trigger('change')

	if $('#ss_theme').length > 0
		$('#ss_theme').trigger('change')

	$('#ss_industry_opt').on "select2-selecting", (e) ->
		e.preventDefault
		$('#ss_industry_opt').trigger('change')
		return

	$('#ss_theme_opt').on "select2-selecting", (e) ->
		e.preventDefault
		$('#ss_theme_opt').trigger('change')
		return

	$('#ss_suggested_opt').on "select2-selecting", (e) ->
		e.preventDefault
		$('#ss_suggested_opt').trigger('change')
		return

	$('#ss_industry_opt').on "change", (e) ->
		$("#ss_final_option").html($( "#ss_industry_opt option:selected" ).text())
		$("#next-service-select").attr('data-service',$(this).val())

	$('#ss_theme_opt').on "change", (e) ->
		$("#ss_final_option").html($( "#ss_theme_opt option:selected" ).text())
		$("#next-service-select").attr('data-service',$(this).val())

	$('#ss_suggested_opt').on "change", (e) ->
		$("#ss_final_option").html($( "#ss_suggested_opt option:selected" ).text())
		$("#next-service-select").attr('data-service',$(this).val())

	$("#next-service-select").on "click", (e) ->
		e.preventDefault()
		service = $(this).attr('data-service')
		if service == ''
			alert('Select a service')
		else
			href = "/customers/"+$(this).data('customer')+"/evaluations/"+$(this).data('evaluation')+"/evaluation_results/new?service_id="+service
			window.location.href = href





