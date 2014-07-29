class SurveysController < ApplicationController
  before_action :authenticate_user!, only: [:activate, :close, :destroy]
  layout 'survey_builder', only: [:new, :show]

  def index
    @surveys = Survey.all
  end

  def new
    @survey = Survey.new
    @flash = t('flash', scope: 'surveys.survey_builder').to_json
  end

  def create
    @survey = Survey.find_or_create_by(id: params[:id])
    @flash = t('flash', scope: 'surveys.survey_builder')
    
    @survey.update_attributes(
      title: params[:title],
      status: 'editing',
      guid: make_guid(params[:title], @survey.id)
    )
    if current_user
      @survey.user_id = current_user.id
      @survey.save
    end

    render json: @survey
  end

  def preview
    @survey = Survey.find(params[:id])
    render layout: 'preview'
  end

  def show
    @survey = Survey.find(params[:id])
    @flash = t('flash', scope: 'surveys.survey_builder').to_json

    if @survey.status == 'editing'
      respond_to do |format|
        format.html
        format.json { render json: @survey, include: :inputs }
        format.xml { response.headers['Content-Disposition'] = "attachment; filename='#{@survey.title}.xml'" }
      end
    else
      render :launch
    end  
  end

  def launch
    @survey = Survey.find(params[:id])
  end

  def activate
    @survey = Survey.find(params[:id])
    @survey.update_attribute(:status, 'active')

    redirect_to action: 'show'
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
