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

#load env variables
config = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))
config.merge! config.fetch(Rails.env, {})
config.each do |key, value|
  ENV[key] = value.to_s unless value.kind_of? Hash
end

module PromiseTracker
  class Application < Rails::Application
    I18n.config.enforce_available_locales = true
 
    # tell the I18n library where to find translations
    I18n.load_path += Dir[Rails.root.join('locale', '*.{rb,yml}')]
     
    # set default locale to :en
    I18n.default_locale = :en

    # handle status codes in routes
    config.exceptions_app = self.routes

    # auto load lib files
    config.autoload_paths << Rails.root.join('lib')

    config.middleware.insert_before "ActionDispatch::Static", "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    config.generators do |g|
      g.factory_girl false
    end
    
  end
end
