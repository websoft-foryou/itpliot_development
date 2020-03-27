Date::DATE_FORMATS.merge!( { default: '%d, %b %Y' } )
Time::DATE_FORMATS.merge!( { default: "%d, %b %Y %H:%M" } )

Time::DATE_FORMATS[:date] = "%m-%d-%Y"