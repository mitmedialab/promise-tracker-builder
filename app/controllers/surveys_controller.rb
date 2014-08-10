require 'rexml/document'

class SurveysController < ApplicationController
  before_action :authenticate_user!, only: [:activate, :close, :destroy, :clone]
  layout 'survey_builder', only: [:new, :show]

  def index
    @surveys = Survey.all
  end

  def new
    if current_user
      @campaign = Campaign.find(params[:campaign_id])
      @survey = Survey.create(campaign_id: @campaign.id, title: @campaign.title)
      redirect_to survey_path(@survey)
    else
      @survey = Survey.new
    end
    @flash = t('survey_builder', scope: 'surveys').to_json
  end

  def create
    @survey = Survey.find_or_create_by(id: params[:id])
    @flash = t('flash', scope: 'surveys.survey_builder')
    
    @survey.update_attributes(
      title: params[:title],
      campaign_id: params[:campaign_id]
    )

    @survey.guid =  make_guid(params[:title], @survey.id)

    if current_user
      @survey.user_id = current_user.id
    end
    @survey.save

    render json: @survey
  end

  def preview
    @survey = Survey.find(params[:id])
    render layout: 'preview'
  end

  def show
    @survey = Survey.find(params[:id])
    @flash = t('survey_builder', scope: 'surveys').to_json

    respond_to do |format|
      format.html
      format.json { render json: @survey, include: :inputs }
    end 
  end

  def get_xml
    @survey = Survey.find(params[:id])
    render_to_string(layout: "surveys/xml")
  end

  def launch
    @survey = Survey.find(params[:id])
  end

  def activate
    @survey = Survey.find(params[:id])
    xml_string = ApplicationController.new.render_to_string(template: "surveys/xform", locals: { survey: @survey })
    aggregate = OdkInstance.new("http://18.85.22.29:8080/ODKAggregate/")
    status = aggregate.uploadXmlform(xml_string)

    if status == 201
      @survey.update_attribute(:status, 'active')
      flash.now[:notice] = t('.upload_success')
      render action: 'launch'
    else
      flash.now[:notice] = t('.upload_error')
      render :launch
    end

  end

  def close
    @survey = Survey.find(params[:id])
    @survey.update_attribute(:status, 'closed')

    redirect_to action: 'show'
  end

  def update
    @survey = Survey.find(params[:id])
    inputs = params[:inputs]

    inputs.each_with_index do |input, index|
      item = Input.find_or_create_by(id: input[:id])
      item.update_attribute(:order, index)
    end

    render nothing: true

  end

  def destroy
    Survey.delete(params[:id])
    @surveys = current_user.surveys
    redirect_to controller: 'users', action: 'show', id: current_user.id
  end

  private 

  def survey_params(params)
    params.require(:survey).permit(:title)
  end



end
