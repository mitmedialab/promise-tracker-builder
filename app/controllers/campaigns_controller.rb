class CampaignsController < ApplicationController
  layout 'form', only: [:edit]

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = current_user.campaigns.create(campaign_params)
    redirect_to edit_campaign_path(@campaign)
  end

  def show
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @flash = t('edit', scope: 'campaigns').to_json
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    redirect_to campaign_path(@campaign)
  end

  def clone
    @campaign = Campaign.find(params[:id])

    @campaign_clone = @campaign.dup
    @campaign_clone.update_attributes(
      title: @campaign.title + " #{t('campaigns.status.copy')}",
      status: 'draft'
    )

    @survey_clone = @campaign.survey.dup
    @survey_clone.save

    @survey_clone.update_attributes(
      campaign_id: @campaign_clone.id,
      guid: make_guid(@campaign_clone.title, @survey_clone.id)
    )

    @campaign.survey.inputs.each do |input|
      @survey_clone.inputs << input.dup
    end

    current_user.campaigns << @campaign_clone
    redirect_to campaign_path(@campaign_clone)
  end

  def destroy
    Campaign.delete(params[:id])
    redirect_to controller: 'users', action: 'show', id: current_user.id
  end


  private

  def campaign_params
    params.require(:campaign).permit(:title, :goal, :data_collectors, :submissions_target, :audience)
  end

end
