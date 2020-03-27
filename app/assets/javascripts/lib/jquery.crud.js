

( function($){
	$.fn.crud = function(options){
		var settings = $.extend( {}, $.fn.crud.defaults, options );
		var $this = $(this)
		var current_index = $this.children(settings.item_class).size() - 1
		
		
		
		var new_entity = function(e){
			e.preventDefault()
			
			new_item = $this.children(settings.item_class).eq(current_index).clone()
			
			current_index++;
			settings.beforeAdd(new_item)
			
			new_item.find(".deletable").remove()
			new_item.find("input:regex(name, .+[id]$)").remove()
			
			new_item.find("label").each( function(){
				if( $(this).attr("for") ){
					$(this).attr("for", $(this).attr("for").replace( /_([0-9]+)_/, "_" + current_index + "_") )
				}
			})
			new_item.find("input, textarea, select").each( function(){
				$(this).attr("id", $(this).attr("id").replace( /_([0-9]+)_/, "_" + current_index + "_") )
				$(this).attr("name", $(this).attr("name").replace( /\[([0-9]+)\]/, "[" + current_index + "]") )
				if( $(this).attr("data-new_item_context") ){
					$(this).attr("data-new_item_context", $(this).attr("data-new_item_context").replace( /\[([0-9]+)\]/, "[" + current_index + "]") )
				}
			})
			new_item.find(".delete").eq(0).show()
			new_item.show()
			
			$this.children(settings.item_class).eq(current_index-1).after(new_item)
			
			settings.onAdd(new_item)
			settings.onChange()
			toggle_add('add')
		}
		
		var delete_entity = function(e){
			e.preventDefault()
			
			var delete_item = $(e.target).closest(settings.item_class)
			if( delete_item.next().is("input[type=hidden]") && delete_item.next().attr("id").match(/_id$/) ){
				id = delete_item.next().clone()
				id.attr("id", id.attr("id").replace(/_[^\_]+$/, "__destroy") )
				id.attr("name", id.attr("name").replace(/\[[^\]]+\]$/, "[_destroy]") )
				id.val("true")
				delete_item.after(id)
				delete_item.hide()
			} else {
				delete_item.remove()
				current_index--;
			}
			settings.onChange()
			toggle_add('del')
		}

		var toggle_add = function(action){
			max = settings.max_children
			if(max < 1){return}
			if(action == 'add' && current_index >= max - 1){
				$this.find(settings.new_button_container_class).hide()
			}else if( action == 'del' && current_index <= max){
				$this.find(settings.new_button_container_class).show()
			}else if( action == 'init' && current_index >= max-1){
				$this.find(settings.new_button_container_class).hide()
			}
		}
		
		
		
		
		
		var init = function(){
			if( !settings.include_delete_button_on_first_el ){
				$this.children(settings.item_class).eq(0).find(settings.delete_button_container_class).hide()
			}
			$this.find(settings.new_button_container_class).append("<a href='#' id='new_"+settings.property+"_link' class='with_icon_and_text button'><span class='icon new_event'></span>"+
				settings.new_button_text+"</a>")
			toggle_add('init')
		}
		
		//Events
		$this.on("click", "#new_"+settings.property+"_link", new_entity)
		$this.on("click", settings.delete_button_container_class+" a", delete_entity)
		
		init()
		
	}
	
	
	$.fn.crud.defaults = {
		property: "entity",
		item_class: ".children",
		new_button_text: "Add new",
		new_button_container_class: ".new_item",
		delete_button_container_class: ".delete",
		include_delete_button_on_first_el: false,
		beforeAdd: function(el){},
		onAdd: function(el){},
		onChange: function(){},
		max_children: 100
		
	}
	
}(jQuery) );

jQuery.expr[':'].regex = function(elem, index, match) {
    var matchParams = match[3].split(','),
        validLabels = /^(data|css):/,
        attr = {
            method: matchParams[0].match(validLabels) ? 
                        matchParams[0].split(':')[0] : 'attr',
            property: matchParams.shift().replace(validLabels,'')
        },
        regexFlags = 'ig',
        regex = new RegExp(matchParams.join('').replace(/^\s+|\s+$/g,''), regexFlags);
    return regex.test(jQuery(elem)[attr.method](attr.property));
}
	