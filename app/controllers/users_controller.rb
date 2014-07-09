class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def show
    @surveys = current_user.surveys
  end

end