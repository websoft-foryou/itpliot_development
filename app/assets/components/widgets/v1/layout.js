//= require jquery
//= require jquery_ujs
//= require rails.validations


window.ClientSideValidations.formBuilders['ActionView::Helpers::FormBuilder'] = {
  add: function(element, settings, message) {
    $(element).parent('.form-group').addClass("has-error");
    if($(element).siblings('span.help-block.error').length > 0){
      $(element).siblings('span.help-block.error').html(message);
    }
    else {
      $(element).after($('<span>').attr('class', 'help-block error').html(message));
    }
  },
  remove: function(element, settings) {
    $(element).parent('.form-group').removeClass("has-error");
    $(element).siblings('span.help-block.error').remove()
  }
}


var onCaptchaSucces = function(){
  $("#recaptcha_container").addClass("hidden")
  $("#submit_container").removeClass("hidden")
}

$(function(){
  $("#new_user").on("submit", function(e){
    if(!$("#accept_terms").is(":checked")){
      e.preventDefault();
      alert($("#accept_terms").data("error-message"));
      return false;
    }
  })
  $('#user_role_type').on("change", function(e) {
      const val = e.currentTarget.value
      if (val == 1 || val == 2) {
          $.ajax({
              url: '/members/parent_companies?role_type='+val,
              dataType: 'json',
              success: function(data) {
                  var html = ''
                  data.forEach(function(company) {
                      html += "<option value='" + company.id + "'>" + company.name + "</option>"
                      $('#invitation_parent_company_id').html(html)
                      $("#invitation_parent_company_id").attr('disabled', false)
                      return
                  })
              },
              error: function(jq,status,data) {
                  alert(data)
                  return
              }
          })
      } else {
          $('#invitation_parent_company_id').html('')
          $("#invitation_parent_company_id").attr('disabled', true)
      }

  })
})
