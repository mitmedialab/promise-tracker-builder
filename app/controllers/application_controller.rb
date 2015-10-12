class ApplicationController < ActionController::Base
  include Exceptions
  
  before_action :set_locale
  after_filter :set_csrf_cookie
  rescue_from Exceptions::Forbidden, with: :rescue_from_forbidden
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  def after_sign_in_path_for(resource)
    campaigns_path
  end

  def get_translations(entry, scope)
    t(entry, scope: scope) 
  end

  def input_types
    I18n.t("activerecord.options.input_types").map { |key, value| { label: value, input_type: key } }
  end

  def sensor_types
    I18n.t("activerecord.options.sensor_types").map { |key, value| { label: value, input_type: key } }
  end

  def threshold_is_upper_limit_options
    I18n.t("activerecord.options.threshold_is_upper_limit").map { |key, value| { value: key, label: value } }
  end

  def export_i18n_messages
    SimplesIdeias::I18n.export! if Rails.env.development?
  end

  def default_serializer_options
    { root: false }
  end

  protected

  def set_csrf_cookie
    if protect_against_forgery?
      cookies['XSRF-TOKEN'] = form_authenticity_token
    end
  end

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end

  def rescue_from_forbidden
    render 'errors/403', layout: 'application', status: 403
  end

end
