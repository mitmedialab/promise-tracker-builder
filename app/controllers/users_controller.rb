class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def show
    @surveys = current_user.surveys.sort_by &:status
  end

end