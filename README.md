# itpliot_development

# Introduction 
Back-end of https://itpilot.de

Hosting site: https://app.itpilot.de

# Getting Started
1. Install App

   ? No install.
   
   ? Run <code>rails s</code> or <code>rails server</code> command in the konsole.
   
2. Software dependencies 

   ? Ruby 2.6.5, Rails 5.2.0
   
   ? PostgreSQL 9.2.23

3. releases history

    2020/03/23

4. API references
   No API.

# Build and Test
   
   In the production mode.

   	- If changed .rb file, use <code>systemctl restart httpd</code> command.

	- If changed .css, .js, .erb file, use <code>RAILS_ENV=production bin/rails assets:precompile</code> command and <code>systemctl restart httpd</code> command.

	- If changed schedule.rb file, use <code>whenever --update-crontab</code>
    

