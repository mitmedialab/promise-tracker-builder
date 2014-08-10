class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def show
    @campaigns = current_user.campaigns
  end

end