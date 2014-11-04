class CampaignsController < ApplicationController
  layout 'full-width', only: [:launch, :monitor, :show, :share, :index]

  def index
    @campaign = Campaign.new
    @campaigns = current_user.campaigns.sort_by(&:status)
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = current_user.campaigns.create(campaign_params)
    redirect_to campaign_goals_wizard_path(@campaign)
  end

  def show
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
    @flash = t('survey_builder', scope: 'surveys').to_json
    @validations = t('validations', scope: 'defaults').to_json
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @flash = t('edit', scope: 'campaigns').to_json
    @validations = t('validations', scope: 'defaults').to_json
  end

  def goals_wizard
    @campaign = Campaign.find(params[:id])
    @flash = t('edit', scope: 'campaigns').to_json
    @validations = t('validations', scope: 'defaults').to_json
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    if @campaign.survey
      @campaign.survey.update_attribute(:title, @campaign.title)
    end
    
    redirect_to campaign_path(@campaign)
  end

  def clone
    campaign = Campaign.find(params[:id])
    campaign_clone = campaign.clone
    title = campaign.title + " #{t('campaigns.status.copy')}"
    campaign_clone.update_attribute(
      :title,
      title + " #{Campaign.where(title: title).count if Campaign.where(title: title).count > 0}"
    )

    campaign_clone.survey = campaign.survey.clone
    campaign_clone.survey.update_attribute(:title, campaign_clone.title)

    current_user.campaigns << campaign_clone
    redirect_to campaign_path(campaign_clone)
  end

  def launch
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
    @flash = t('survey_builder', scope: 'surveys').to_json
    @validations = t('validations', scope: 'defaults').to_json
    @input_types = input_types.to_json

    if @campaign.status != "draft"
      redirect_to monitor_campaign_path(@campaign)
    end
  end

  #Post survey definition to Aggregator
  def activate
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey

    if @survey.activate['status'] == 'success'
      @campaign.update_attribute(:status, 'active')
      flash.now[:notice] = t('.upload_success')
      @campaign.update_attribute(:start_date, Time.now)
      redirect_to monitor_campaign_path(@campaign)
    else
      flash.now[:notice] = t('.upload_error')
      render :launch
    end
  end

  def monitor
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def share
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def close
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey

    if @survey.close['status'] == 'success'
      @campaign.update_attribute(:status, 'closed')
      redirect_to share_campaign_path(@campaign)
    end
  end

  def destroy
    Campaign.delete(params[:id])
    redirect_to campaigns_path
  end


  private

  def campaign_params
    params.require(:campaign).permit(:title, :description, :goal, :theme, :data_collectors, :submissions_target, :audience)
  end

end
