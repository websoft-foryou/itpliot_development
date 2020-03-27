$ ->
  $('#user_role_type').change (e) ->
    val = e.val
    $("#reload_opt_tree #cu_options_tree").attr('disabled', val!="")
    # $("#reload_opt_tree #cu_options_tree").select2("val", "");
    if val == "1" || val == "2"
      $.ajax
        url: '/members/parent_companies?role_type='+val
        dataType: 'json'
        success: (data) ->
          html = ''
          data.forEach (company) ->
            html += "<option value='"+company.id+"'>" + company.name + "</option>"
          #console.log html
          $('#invitation_parent_company_id').html(html)
          $("#invitation_parent_company_id").select2()
          $("#invitation_parent_company_id").attr('disabled', false)
          return
        error: (jq,status,data) ->
          alert(data)
          return
    else
      $('#invitation_parent_company_id').html('')
      $("#invitation_parent_company_id").select2()
      $("#invitation_parent_company_id").attr('disabled', true)



