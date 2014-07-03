class InputsController < ApplicationController

  def new
    binding.pry
  end

  def create
    form = Form.find(params[:input][:form_id])
    input = params[:input]

    @input = form.inputs.find_or_create_by(id: input[:id])
    @input.update_attributes(input_params(params))
    @input.update_attribute(:uid, make_uid(@input.label, @input.id))

    render json: @input
  end

  def destroy
    Input.find(params[:id]).destroy
    render json: {message: "Input deleted"}
  end


  private

  def input_params(params)
    params.require(:input).permit(:label, :required, :input_type, :order, :options, :form_id)
  end

end
