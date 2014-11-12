require 'rexml/document'

class SurveysController < ApplicationController
  before_action :authenticate_user!, except: [:test_builder, :new]

  layout 'survey_builder', only: [:test_builder, :show]

  def index
    @surveys = Survey.all
  end

  def new
    if current_user
      @campaign = Campaign.find(params[:campaign_id])
      @survey = Survey.create(
        campaign_id: @campaign.id,
        title: @campaign.title
      )
      redirect_to survey_path(@survey)
    else
      redirect_to test_builder_path
    end
  end

  def test_builder
    @survey = Survey.new(title: t('surveys.survey_builder.untitled'))
    @flash = t('survey_builder', scope: 'surveys').to_json
    @validations = t('validations', scope: 'defaults').to_json
    @input_types = input_types.to_json
  end

  def update
    @survey = Survey.find(params[:id])
    @survey.update_attribute(:title, params[:title])

    render json: @survey
  end

  def save_order
    @survey = Survey.find(params[:id])
    inputs = params[:inputs]

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
      format.json { render json: @survey, root: false }
    end 
  end

  def destroy
    Survey.delete(params[:id])
    @surveys = current_user.surveys
    redirect_to controller: 'users', action: 'show', id: current_user.id
  end

end
