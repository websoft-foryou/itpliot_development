require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ItPilot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    config.autoload_paths += %W(#{config.root}/logical)


    config.i18n.available_locales = %w(en de)


    config.action_mailer.asset_host = 'http://itpilot.companycloud.de:81'

    config.active_support.escape_html_entities_in_json = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
