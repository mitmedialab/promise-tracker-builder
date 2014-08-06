class CampaignsController < ApplicationController
  layout 'form', only: [:edit]

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.create(campaign_params)
    redirect_to edit_campaign_path(@campaign)
  end

  def show
    @campaign = Campaign.find(params[:id])
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    redirect_to campaign_path(@campaign)
  end

  def destroy
  end


  private

  def campaign_params
    params.require(:campaign).permit(:title, :goal)
  end

end
