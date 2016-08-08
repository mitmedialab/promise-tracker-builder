class CampaignsController < ApplicationController

  layout 'campaign', except: [:index, :public_profile, :setup, :get_stats]
  before_filter :authenticate_user!, except: [:public_profile, :share]
  before_filter :restrict_user_access, except: [:create, :index, :public_profile, :share, :clone, :get_stats]
  before_filter :assign_campaign_variables, except: [:index, :create, :destroy, :share, :get_stats]

  def index
    @campaign = Campaign.new
    @campaigns = current_user.campaigns.select{ |c| c.title.present? }.sort_by(&:status)
  end

  def new
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = current_user.campaigns.find_or_create_by(id: params[:campaign][:id])
    @campaign.update_attributes(campaign_params)
    if campaign_params[:city]
      tag = Tag.find_or_create_by(label: campaign_params[:city])
      @campaign.tags.push(tag)
    end
    redirect_to edit_campaign_path(@campaign)
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
      redirect_to :back, flash: { error: permission }
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

    if params[:campaign][:redirect_action] && @campaign.campaign_page_valid
      redirect_to action: params[:campaign][:redirect_action]
    else
      redirect_to action: @campaign.get_latest_state, id: @campaign.id
    end
  end

  def survey
    @input_types = input_types.to_json
  end

  def profile
    @input_types = input_types.to_json
    if !current_user
      render layout: 'application'
    end
  end

  def edit_profile
    @input_types = input_types.to_json
  end

  def public_profile
    @input_types = input_types.to_json
  end

  def setup
  end

  def test
    @input_types = input_types.to_json
    if @campaign.status == 'draft'
      @survey.activate('test')
    end
  end

  def activate
    if @survey.activate(params[:status])['status'] == 'success'
      if params[:status] == 'test'
        redirect_to test_campaign_path(@campaign)
      elsif params[:status] == 'active'
        redirect_to campaign_collect_path(@campaign)
      end
    else
      redirect_to request.referer, flash: {error: t('.upload_error')}
    end
  end

  def collect
  end

  def share
    assign_campaign_variables
    @input_types = input_types.to_json
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
    campaign_clone = @campaign.clone
    title = @campaign.title + " #{t('campaigns.status.copy')}"
    campaign_clone.update_attributes(
      title: title + " #{Campaign.where(title: title).count if Campaign.where(title: title).count > 0}",
      organizers: nil,
      status: 'draft'
    )

    if @campaign.survey
      campaign_clone.survey = @campaign.survey.clone
      campaign_clone.survey.update_attribute(:title, campaign_clone.title)
    end

    current_user.campaigns << campaign_clone
    redirect_to edit_campaign_path(campaign_clone)
  end

  def destroy
    Campaign.delete(params[:id])
    redirect_to campaigns_path
  end

  def get_stats
    @users = User.all
    @campaigns = Campaign.all
  end


  private

  def restrict_user_access
    @campaign = Campaign.find(params[:id])
    raise Exceptions::Forbidden unless current_user.owns?(@campaign)
  end

  def get_next_state(current_action)
    case current_action
    when 'edit', 'goals_wizard', 'goals'
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
    when 'goals'
      true
    when 'survey'
      if @survey && @survey.inputs.length > 0
        true
      else
        t('defaults.validations.please_create_survey')
      end
    when 'edit_profile', 'profile'
      if @campaign.campaign_page_valid
        true
      else
        t('defaults.validations.please_complete_campaign_page')
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
    find_campaign_by_id_or_code
    @can_advance = campaign_can_advance?(params[:action])
  end

  def find_campaign_by_id_or_code
    if params[:id]
      @campaign = Campaign.includes(survey: :inputs).find(params[:id])
      @survey = @campaign.survey
    elsif params[:code]
      @survey = Survey.includes(:inputs, :campaign).find_by(code: params[:code].split("-").join)
      @campaign = @survey.campaign
    end
  end

  def campaign_params
    params.require(:campaign).permit(
      :title, :description, :goal, :theme, :data_collectors,
      :submissions_target, :audience, :organizers, :anonymous, :image, :campaign_page_valid, :country, :city)
  end

end
