class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def index
    redirect_to root_path
  end

  def show
    @campaigns = current_user.campaigns.sort_by(&:status)
  end

end