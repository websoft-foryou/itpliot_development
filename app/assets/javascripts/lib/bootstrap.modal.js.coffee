# $ ->
#     $("body").on 'click.bs.modal.data-api', '[data-toggle="modal"]', (e) ->
#         $this   = $(@)
#         href    = $this.attr('href')
#         e.preventDefault() if $this.is('a')
        
#         if $this.attr('data-target')
#             $target = $($this.attr('data-target') || (href && href.replace(/.*(?=#[^\s]+$)/, ''))) #strip for ie7
#             option  = $target.data('bs.modal') ? 'toggle' : $.extend({ remote: !/#/.test(href) && href }, $target.data(), $this.data())

#             $target
#             .modal( option, @ )
#             .one 'hide', ->
#                 $this.is(':visible') && $this.focus()

#         else
#             if !(href.indexOf('#') == 0)
#                 $modal_id = $this.data("modal-id") || ""
#                 $container = $("<div class='modal fade' id='#{$modal_id}' aria-hidden='true' tabindex='-1' role='dialog' aria-labelledby='#{$modal_id}_labelby'><div class='modal-dialog'><div class='modal-content'><h2 class='text-center m-b-large'><i class='fa fa-lg fa-spinner fa-spin'></i></h2></div></div></div>")
#                 $container.appendTo(document.body)
#                 $container.modal().on 'hidden.bs.modal', ->
#                     $("##{$modal_id}").remove()
#                     $('.modal-backdrop.in').each ->
#                         $(this).remove()
#                 $.ajax
#                     url: href
#                     dataType: "script"
#                     type: "GET"
#                     # success: ->
#                         # $container.find('input:text:visible:first').focus()
                    
      

#     $(document)
#         .on 'show.bs.modal', '.modal', -> 
#             $(document.body).addClass('modal-open')
#         .on "shown.bs.modal", '.modal', ->
#             $("form[data-validate]", $(@)).validate()
#         .on 'hidden.bs.modal', '.modal', -> 
#             $(document.body).removeClass('modal-open')