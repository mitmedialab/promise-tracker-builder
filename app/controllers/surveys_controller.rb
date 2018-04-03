class SurveysController < ApplicationController
  before_action :authenticate_user!, except: [:test_builder, :new, :show, :fill_out]
  before_action :restrict_user_access, except: [:test_builder, :new, :show, :fill_out]
  layout 'survey_builder', only: [:test_builder, :edit]

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
      redirect_to edit_survey_path(@survey)
    else
      redirect_to test_builder_path
    end
  end

  def test_builder
    @survey = Survey.new(title: t('surveys.survey_builder.untitled'))
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
    
    if inputs
      inputs.each_with_index do |input, index|
        item = Input.find_or_create_by(id: input[:id])
        item.update_attributes(input.permit(:id, :survey_id, :label, :input_type, :options, :required, :order))
        item.update_attribute(:order, index)
        item.delete if input["label"].blank?
      end
    end

    if @survey.campaign.status == 'draft'
      render json: {redirect_path: 'campaign_survey_path'}.to_json
    else @survey.campaign.status == 'test'
      @survey.activate('test')
      render json: {redirect_path: 'test_campaign_path'}.to_json
    end
  end

  def show
    @survey = Survey.find(params[:id])
    render json: @survey
  end

  def edit
    @survey = Survey.find(params[:id])
    @input_types = input_types.to_json
  end

  def fill_out
    @code = params[:code]
  end

  def destroy
    Survey.delete(params[:id])
    @surveys = current_user.surveys
    redirect_to controller: 'users', action: 'show', id: current_user.id
  end

  private

  def restrict_user_access
    @survey = Survey.find(params[:id])
    raise Exceptions::Forbidden unless current_user.owns?(@survey.campaign)
  end

end
