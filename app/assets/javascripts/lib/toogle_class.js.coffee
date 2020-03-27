$ ->
  $("body").on "click", '[data-toggle^="class"]', window.toggleCssClass

window.toggleCssClass = (e)->
  e?.preventDefault() unless $(e.target).data("behaviour") and $(e.target).data("behaviour") == "default" #Does not prevnentDefault if behaviour is default
  $this = $(e.target)
  !$this.data('toggle') && ($this = $this.closest('[data-toggle^="class"]'))
  $class = $this.data()['toggle'].split(':')[1]
  $target = $( $this.data('target') || $this.attr('href') )

  if $class == "js_hide"
    $target.slideToggle 500, -> $(@).css "overflow", ""
  else
    $target.toggleClass($class)

  if $target.hasClass("active")
    $target.find(".text-active input").attr("checked", "checked")
    $target.find(".text input").removeAttr("checked").trigger("change")
  else
    $target.find(".text input").attr("checked", "checked")
    $target.find(".text-active input").removeAttr("checked").trigger("change")
  $this.toggleClass('active')
  if $this.hasClass("active")
    $("form[data-validate]", $target).validate()
    $target.find(".focus-on-show").focus()
