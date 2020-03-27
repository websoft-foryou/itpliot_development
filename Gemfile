source 'http://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'pg'
gem 'rails', '~> 5.2.0'

gem 'bootsnap', require: false

gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
gem 'jquery-fileupload-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.1'
gem 'non-stupid-digest-assets'
gem 'sass-rails', '~> 5.0'
gem 'sprockets', ' ~> 3.7'
gem 'therubyracer', platforms: :ruby
gem 'uglifier',     '>= 2.7.2'

gem 'faker'
gem 'rack-test', '0.7.0'

gem 'client_side_validations'

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'bootstrap-sass', '~> 3.1.1'
gem 'font-awesome-rails'

gem 'globalize', '~> 5.1.0', git: 'https://github.com/globalize/globalize'

gem 'recaptcha'

# devise
gem 'devise', '>= 4.0'
gem 'devise-async'
gem 'devise_invitable', '~> 1.7.0'

gem 'will_paginate'

gem 'paperclip', '~> 6.0.0'

gem 'acts_as_list'

gem 'jquery-turbolinks', '1.0.0'
gem 'turbolinks'

gem 'rabl'
gem 'rgl'
gem 'ruby-graphviz'

gem 'deep_cloneable', '~> 2.3.0'

gem 'ckeditor', '~> 4.2.4'

group :production do
  gem 'exception_notification'
  gem 'test-unit'
end

group :test do
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'rubocop'
  gem 'simplecov'
  gem 'terminal-notifier-guard'
  gem 'rspec-json_expectations'
  gem 'test-prof'
end

group :development do
  # gem 'quiet_assets'

  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
end

gem 'dotenv-rails', groups: %i[development test]

gem 'puma', '~> 3.7'

group :development, :test do
  gem 'awesome_print'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.2'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.7'
  gem 'selenium-webdriver'
  gem 'table_print'
end

gem "auto_strip_attributes", "~> 2.5"

gem 'rubyzip', '~> 1.1.0'
gem 'axlsx', '2.1.0.pre'
gem 'axlsx_rails'
gem 'zip-zip'

gem 'whenever', require: false

gem 'httparty'