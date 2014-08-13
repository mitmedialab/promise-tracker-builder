class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def after_sign_in_path_for(resource)
    campaigns_path
  end

  def make_guid(string, id)
    "#{string.downcase.scan(/\w+/).join("_")}_#{id}"
  end

  def get_translations(entry, scope)
    t(entry, scope: scope) 
  end

  def input_types
    I18n.t("activerecord.options.input_types").map { |key, value| { label: value, input_type: key } }
  end

end
