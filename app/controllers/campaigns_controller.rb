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
      redirect_to launch_campaign_path(@campaign)
    else
      flash.now[:notice] = t('.upload_error')
      render :launch
    end

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
