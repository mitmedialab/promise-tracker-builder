class CampaignsController < ApplicationController
  layout 'campaign', except: [:index, :public_page]
  before_filter :authenticate_user!, except: [:share, :public_page]

  def index
    @campaign = Campaign.new
    @campaigns = current_user.campaigns.sort_by(&:status)
  end

  def setup
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = current_user.campaigns.find_or_create_by(id: params[:campaign][:id])
    @campaign.update_attributes(campaign_params)
    if @campaign.save
      render js: "window.location = '#{campaign_goals_wizard_path(@campaign)}'"
    else
      render json: { errors: @campaign.errors.full_messages }, status: 422
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @flash = t('edit', scope: 'campaigns').to_json
    @validations = t('validations', scope: 'defaults').to_json
    render layout: 'full-width'
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    if @campaign.survey
      @campaign.survey.update_attribute(:title, @campaign.title)
    end
    
    redirect_to campaign_path(@campaign)
  end

  def show
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
    @flash = t('survey_builder', scope: 'surveys').to_json
    @validations = t('validations', scope: 'defaults').to_json
  end

  def goals_wizard
    @campaign = Campaign.find(params[:id])
    @flash = t('edit', scope: 'campaigns').to_json
    @validations = t('validations', scope: 'defaults').to_json

    render layout: 'full-width'
  end

  def launch
    @campaign = Campaign.find(params[:id])
    if @campaign.validate_public_page
      redirect_to test_path(@campaign)
    else
      redirect_to edit_public_campaign_path(@campaign)
    end
  end

  def public_page
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def edit_public_page
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def update_public_page
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def test
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

  def clone
    campaign = Campaign.find(params[:id])
    campaign_clone = campaign.clone
    title = campaign.title + " #{t('campaigns.status.copy')}"
    campaign_clone.update_attribute(
      :title,
      title + " #{Campaign.where(title: title).count if Campaign.where(title: title).count > 0}"
    )

    if campaign.survey
      campaign_clone.survey = campaign.survey.clone
      campaign_clone.survey.update_attribute(:title, campaign_clone.title)
    end

    current_user.campaigns << campaign_clone
    redirect_to campaign_path(campaign_clone)
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
