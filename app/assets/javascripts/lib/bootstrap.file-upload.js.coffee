$ ->
	$("form.basic_file_upload").each ->
		if $(@).attr("data-type")?
			window.addFileUpload $(@), $(@).data("type")
		else
			window.addFileUpload $(@)

window.addFileUpload = (form, type='') ->
	form.fileupload
		dataType: "script"
		sequentialUploads: true
		dropZone: form
		add: (e, data) ->
			if type != ''
				types = new RegExp("(\.|\/)(#{type})$", "i")
			else
				types = /(\.|\/)(gif|jpe?g|png|bmp)$/i
			file = data.files[0]
			if types.test(file.type) || types.test(file.name)
				data.context = $( "<div class='overlayer photo-loading'><i class='fa fa-spinner fa-spin'></i></div>" )
				t = if $(e.target).data("loading-placeholder") then $(e.target).find($(e.target).data("loading-placeholder")) else $(e.target)
				t.after(data.context)
				data.submit()
			else
				alert("Unsupported file type")
		done: (e, data) ->
			data.context.remove()