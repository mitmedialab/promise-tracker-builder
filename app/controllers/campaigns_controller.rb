class CampaignsController < ApplicationController

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.create(campaign_params)
    redirect_to action: 'show'
  end

  def show
    @campaign = Campaign.find(params[:id])
  end

  def edit
  end

  def update
  end

  def destroy
  end


  private

  def campaign_params
    params.require(:campaign).permit(:title, :goal)
  end

end
