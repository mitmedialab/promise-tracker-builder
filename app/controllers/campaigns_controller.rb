class CampaignsController < ApplicationController
  layout 'dark', only: [:goals_wizard, :edit]
  layout 'full-width', only: [:launch, :monitor, :share]

  def index
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

    if @campaign.status != "draft"
      redirect_to monitor_campaign_path(@campaign)
    end
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

  def launch
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
    @validations = t('validations', scope: 'defaults').to_json
    @input_types = input_types.to_json

    if @campaign.status != "draft"
      redirect_to monitor_campaign_path(@campaign)
    end
  end

  def activate
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
    xml_string = ApplicationController.new.render_to_string(template: "surveys/xform", locals: { survey: @survey })
    aggregate = OdkInstance.new("http://18.85.22.29:8080/ODKAggregate/")
    status = aggregate.uploadXmlform(xml_string)

    if status == 201
      @campaign.update_attribute(:status, 'active')
      flash.now[:notice] = t('.upload_success')
      @campaign.update_attribute(:start_date, Time.now)
      redirect_to launch_campaign_path(@campaign)
    else
      flash.now[:notice] = t('.upload_error')
      render :launch
    end
  end

  def monitor
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey

    #Mockup hack
    @responses = 3.5 + rand(@campaign.submissions_target)
  end

  def share
    @campaign = Campaign.find(params[:id])
    @survey = @campaign.survey
  end

  def close
    @campaign = Campaign.find(params[:id])
    @campaign.update_attribute(:status, 'closed')

    redirect_to action: 'launch'
  end

  def destroy
    Campaign.delete(params[:id])
    redirect_to controller: 'users', action: 'show', id: current_user.id
  end


  private

  def campaign_params
    params.require(:campaign).permit(:title, :goal, :theme, :data_collectors, :submissions_target, :audience)
  end

end
