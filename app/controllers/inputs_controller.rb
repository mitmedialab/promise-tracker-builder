class InputsController < ApplicationController

  def create
    # survey = Survey.find(params[:input][:survey_id])
    # input = params[:input]
    # binding.pry

    @input = Input.find_or_create_by(id: params[:id])
    @input.update_attributes(input_params)
    @input.guid = make_guid(@input.label, @input.id)

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
    params.require(:input).permit(:survey_id, :label, :input_type, :media_type, :options, :required, :order)
  end

end
