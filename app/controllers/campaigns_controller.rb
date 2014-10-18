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

    render layout: 'dark'
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    if @campaign.survey
      @campaign.survey.update_attribute(:guid, make_guid(@campaign.title, @campaign.id))
    end
    
    redirect_to campaign_path(@campaign)
  end

  def clone
    @campaign = Campaign.find(params[:id])

    @campaign_clone = @campaign.dup
    title = @campaign.title + " #{t('campaigns.status.copy')}"
    @campaign_clone.update_attributes(
      title: title + " #{Campaign.where(title: title).count if Campaign.where(title: title).count > 0}",
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

  #Post survey definition to API
  def activate
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey

    uri = URI('http://dev.aggregate.promisetracker.org/surveys')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    request.body = @survey.to_json(
      only: [:id, :title, :campaign_id], 
      include: { inputs: { only: [:id, :label, :input_type, :order, :options] }}
    )
    response = http.request(request)

    if response.code == '200'
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

    #Mockup hack
    @responses = 0.5 + rand(@campaign.submissions_target)
  end

  def share
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def close
    @campaign = Campaign.find(params[:id])
    uri = URI('http://dev.aggregate.promisetracker.org/surveys' + @campaign.survey.id.to_s + '/close')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request)
    @campaign.update_attribute(:status, 'closed')

    redirect_to share_campaign_path(@campaign)
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
