$ ->
  if $("#price_plan_container").length
    $("#plan_id").on "change", ->
      $("#price_value").text $(@).data($(@).val().toString())
