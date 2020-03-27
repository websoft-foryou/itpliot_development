$(function(){
    $('#sidebar .sub-menu > a').click(function () {
        var last = jQuery('.sub-menu.open', jQuery('#sidebar'));        
        jQuery('.menu-arrow').removeClass('arrow_carrot-right');
        jQuery('.sub', last).slideUp(200);
        var sub = jQuery(this).next();
        if (sub.is(":visible")) {
            jQuery('.menu-arrow').addClass('arrow_carrot-right');            
            sub.slideUp(200);
        } else {
            jQuery('.menu-arrow').addClass('arrow_carrot-down');            
            sub.slideDown(200);
        }
        var o = (jQuery(this).offset());
        diff = 200 - o.top;
        if(diff>0)
            jQuery("#sidebar").scrollTo("-="+Math.abs(diff),500);
        else
            jQuery("#sidebar").scrollTo("+="+Math.abs(diff),500);
    });

    $.cookie("current_timezone", jstz.determine().name(), {
        expires: 365,
        path: '/'
    });


    if (typeof google != 'undefined'){
        var addresspickerMap = $( "#addresspicker_map" ).addresspicker({
          mapOptions: {
            zoom: 4,
            center: new google.maps.LatLng('', ''),
            scrollwheel: false,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          },
          elements: {
            map:      "#map",
            lat:      "#pick_latitude",
            lng:      "#pick_longitude",
            route: '#pick_address',
            // street_number: '#street_number',
            // route: '#route',
            locality: '#pick_city',
            // sublocality: '#sublocality',
            // administrative_area_level_3: '#administrative_area_level_3',
            // administrative_area_level_2: '#administrative_area_level_2',
            // administrative_area_level_1: '#administrative_area_level_1',
            country:  '#pick_country',
            postal_code: '#postal_code',
            // type:    '#type'

          }
        });

        var gmarker = addresspickerMap.addresspicker( "marker");
        gmarker.setVisible(true);
        addresspickerMap.addresspicker( "updatePosition");

        $('#reverseGeocode').change(function(){
          $("#addresspicker_map").addresspicker("option", "reverseGeocode", ($(this).val() === 'true'));
        });

        var map = $("#addresspicker_map").addresspicker("map");
        google.maps.event.addListener(map, 'idle', function(){
          $('#zoom').val(map.getZoom());
        });
    }


});