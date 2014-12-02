class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :set_locale
  after_filter :set_csrf_cookie
 
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

  def export_i18n_messages
    SimplesIdeias::I18n.export! if Rails.env.development?
  end

  private

  def set_csrf_cookie
    if protect_against_forgery?
      cookies['XSRF-TOKEN'] = form_authenticity_token
    end
  end

  # def verified_request?
  #   super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  # end

end
