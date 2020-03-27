CURRENT_HOST = case Rails.env
when 'production' then 'http://itpilot.companycloud.de:81'
when 'preproduction' then 'http://itpilot.companycloud.de:81/'
else
  'http://localhost.ro:3000'
end
