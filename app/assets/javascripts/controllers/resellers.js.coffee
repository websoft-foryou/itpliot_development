$ ->
  $('#company_plan_id').change (e) ->
    optionSelected = $(this).find("option:selected");
    valueSelected  = optionSelected.val();
    #$("#reload_opt_tree #cu_options_tree").attr('disabled', @checked)

  $('#company_is_dsp').change (e) ->
    $('#plan_container').toggle(!e.target.checked)

  $('#plan_id').change (e) -> 
    $('.confirm-new-plan').show()

  $('.confirm-cancel-plan').click (e) ->
    e.preventDefault();
    resellerForm = $('#reseller_plan')
    resellerForm.attr('action', $(this).data('url'));
    resellerForm.submit();
