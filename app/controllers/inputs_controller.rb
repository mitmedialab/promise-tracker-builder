class InputsController < ApplicationController

  def create
    survey = Survey.find(params[:input][:survey_id])
    input = params[:input]

    @input = survey.inputs.find_or_create_by(id: input[:id])
    @input.update_attributes(input_params)
    @input.guid = make_guid(@input.label, @input.id)

    if params[:options]
      options = {}
      params[:options].each_with_index do |option, index|
        options[make_guid(option, index)] = option if option.present?
      end
      @input.options = options
    end
    
    if params[:decimal]
      @input.input_type = 'decimal'
    end
      
    @input.save

    render json: @input
  end

  def clone
    @input = Input.find(params[:id])
    @input_clone = @input.dup
    @input_clone.save

    render json: @input_clone
  end

  def destroy
    Input.find(params[:id]).destroy
    render json: {message: "Input deleted"}
  end


  private

  def input_params
    params.require(:input).permit(:survey_id, :label, :input_type, :media_type, :options, :decimal, :required, :annotate, :order)
  end

end
