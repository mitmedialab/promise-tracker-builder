class UsersController < ApplicationController
  before_filter :authenticate_user! 

  def index
    redirect_to root_path
  end

  def show
    @campaigns = current_user.campaigns.sort_by(&:status)
  end

  def edit
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:notice] = t("defaults.validations.confirm_save")
      redirect_to user_path(current_user)
    else
      flash.now[:error] = current_user.errors.full_messages.to_sentence
      render action: 'edit'
    end
  end


  private

  def user_params
    params.require(:user).permit(:bio, :email, :username)
  end

end