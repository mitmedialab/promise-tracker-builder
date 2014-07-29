class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def show
    @draft_surveys = current_user.surveys.where(status: "editing")
    @active_surveys = current_user.surveys.where(status: "active")
    @closed_surveys = current_user.surveys.where(status: "closed")
  end

end