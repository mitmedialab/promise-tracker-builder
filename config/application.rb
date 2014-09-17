require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PromiseTracker
  class Application < Rails::Application
 
    # tell the I18n library where to find translations
    I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
     
    # set default locale to :en
    I18n.default_locale = :en

    config.middleware.insert_before "ActionDispatch::Static", "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
    
  end
end
