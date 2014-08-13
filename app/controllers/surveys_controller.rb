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

  def update
    @survey = Survey.find(params[:id])
    inputs = params[:inputs]

    @survey.update_attributes(
      title: params[:title],
      campaign_id: params[:campaign_id],
      guid: make_guid(params[:title], @survey.id)
    )

    inputs.each_with_index do |input, index|
      item = Input.find_or_create_by(id: input[:id])
      item.update_attribute(:order, index)
    end

    render nothing: true
  end

  def preview
    @survey = Survey.find(params[:id])
    render layout: 'preview'
  end

  def show
    @survey = Survey.find(params[:id])
    @flash = t('survey_builder', scope: 'surveys').to_json
    @validations = t('validations', scope: 'defaults').to_json
    @input_types = input_types.to_json

    respond_to do |format|
      format.html
      format.json { render json: @survey, include: :inputs }
    end 
  end

  def get_xml
    @survey = Survey.find(params[:id])
    render_to_string(layout: "surveys/xml")
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
