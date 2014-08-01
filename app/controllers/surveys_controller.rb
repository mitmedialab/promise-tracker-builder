class SurveysController < ApplicationController
  before_action :authenticate_user!, only: [:activate, :close, :destroy, :clone]
  layout 'survey_builder', only: [:new, :show]

  def index
    @surveys = Survey.all
  end

  def new
    @survey = Survey.new
    @flash = t('survey_builder', scope: 'surveys').to_json
  end

  def create
    @survey = Survey.find_or_create_by(id: params[:id])
    @flash = t('flash', scope: 'surveys.survey_builder')
    
    @survey.update_attributes(
      title: params[:title],
      status: 'draft',
      guid: make_guid(params[:title], @survey.id)
    )
    if current_user
      @survey.user_id = current_user.id
      @survey.save
    end

    render json: @survey
  end

  def clone
    @survey = Survey.find(params[:id])

    @clone = @survey.dup
    @clone.update_attributes(
      title: @survey.title + " #{t('surveys.status.copy')}",
      status: 'draft',
      guid: make_guid(@clone.title, @clone.id)
    )

    @survey.inputs.each do |input|
      @clone.inputs << input.dup
    end

    current_user.surveys << @clone
    redirect_to survey_path(@clone)
  end

  def preview
    @survey = Survey.find(params[:id])
    render layout: 'preview'
  end

  def show
    @survey = Survey.find(params[:id])
    @flash = t('survey_builder', scope: 'surveys').to_json

    if @survey.status == 'draft'
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
