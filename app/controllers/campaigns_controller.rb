class CampaignsController < ApplicationController

  layout 'campaign', except: [:index, :public_profile, :setup]
  before_filter :authenticate_user!, except: [:profile, :share]
  before_filter :restrict_user_access, except: [:create, :index, :profile, :share]
  before_filter :assign_campaign_variables, except: [:index, :create, :destroy, :share]

  def index
    @campaign = Campaign.new
    @campaigns = current_user.campaigns.sort_by(&:status)
  end

  def new
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = current_user.campaigns.find_or_create_by(id: params[:campaign][:id])
    @campaign.update_attributes(campaign_params)
    redirect_to campaign_goals_wizard_path(@campaign)
  end

  def show
    redirect_to action: @campaign.get_latest_state, id: @campaign.id
  end

  def goals
  end

  def next
    permission = campaign_can_advance?(params[:refer_action])

    if permission == true
      redirect_to action: get_next_state(params[:refer_action]), id: @campaign.id
    else
      render json: { errors: [permission] }.to_json, status: 401
    end
  end

  def goals_wizard
  end

  def edit
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    if @campaign.survey
      @campaign.survey.update_attribute(:title, @campaign.title)
    end

    if params[:campaign][:redirect_action] && @campaign.validate_profile
      redirect_to action: params[:campaign][:redirect_action]
    else
      redirect_to action: @campaign.get_latest_state, id: @campaign.id
    end
  end

  def survey
  end

  def profile
    if !current_user
      render layout: "application"
    end
  end

  def edit_profile
  end

  def public_profile
  end

  def setup
  end

  def test
    if @campaign.status == 'draft'
      @survey.activate('test')
    end
  end

  #Post survey definition to aggregator
  def activate
    if @survey.activate(params[:status])['status'] == 'success'
      flash.now[:notice] = t('.upload_success')

      if params[:status] == 'test'
        redirect_to test_campaign_path(@campaign)
      elsif params[:status] == 'active'
        redirect_to campaign_collect_path(@campaign)
      end
    else
      flash.now[:notice] = t('.upload_error')
      render :test
    end
  end

  def collect
  end

  def share
    @campaign = Campaign.includes(survey: :inputs).find(params[:id])
    @survey = @campaign.survey
    @can_advance = campaign_can_advance?(params[:action])
  end

  def close
    if @survey.close['status'] == 'success'
      @campaign.update_attribute(:status, 'closed')
      redirect_to share_campaign_path(@campaign)
    else
      render 'collect'
    end
  end

  def clone
    campaign = Campaign.find(params[:id])
    campaign_clone = campaign.clone
    title = campaign.title + " #{t('campaigns.status.copy')}"
    campaign_clone.update_attributes(
      title: title + " #{Campaign.where(title: title).count if Campaign.where(title: title).count > 0}",
      organizers: nil,
      status: 'draft'
    )
    campaign.save

    if campaign.survey
      campaign_clone.survey = campaign.survey.clone
      campaign_clone.survey.update_attribute(:title, campaign_clone.title)
    end

    current_user.campaigns << campaign_clone
    redirect_to edit_campaign_path(campaign_clone)
  end

  def destroy
    Campaign.delete(params[:id])
    redirect_to campaigns_path
  end


  private

  def restrict_user_access
    @campaign = Campaign.find(params[:id])
    raise Exceptions::Forbidden unless current_user.owns?(@campaign)
  end

  def get_next_state(current_action)
    case current_action
    when 'edit', 'goals_wizard'
      'survey'
    when 'survey'
      'edit_profile'
    when 'edit_profile', 'profile'
      'test'
    when 'test'
      'collect'
    end
  end

  def campaign_can_advance?(current_action)
    case current_action
    when 'edit', 'goals_wizard'
      t('defaults.validations.please_define_goals')
    when 'survey'
      if @survey && @survey.inputs.length > 0
        true
      else
        t('defaults.validations.please_create_survey')
      end
    when 'edit_profile', 'profile'
      if @campaign.validate_profile
        true
      else
        t('defaults.validations.please_complete_profile')
      end
    when 'test'
      if @campaign.status == 'active'
        true
      else
        t('defaults.validations.launch_campaign')
      end
    end
  end

  def assign_campaign_variables
    @campaign = Campaign.includes(survey: :inputs).find(params[:id])
    @survey = @campaign.survey
    @can_advance = campaign_can_advance?(params[:action])
  end

  def campaign_params
    params.require(:campaign).permit(
      :title, :description, :goal, :theme, :data_collectors,
      :submissions_target, :audience, :organizers, :anonymous, :image)
  end

end
