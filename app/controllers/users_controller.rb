class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def show
    @forms = current_user.forms
  end

end