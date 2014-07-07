class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    user_path(current_user)
  end

  def make_guid(string, id)
    return "#{string.downcase.scan(/\w+/).join("_")}_#{id}"
  end
end
