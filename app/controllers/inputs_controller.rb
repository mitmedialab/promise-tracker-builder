class InputsController < ApplicationController

  def new
    binding.pry
  end

  def create
    form = Form.find(params[:input][:form_id])
    input = params[:input]

    @input = form.inputs.find_or_create_by(id: input[:id])
    @input.update_attributes(input_params(params))
    @input.guid = make_guid(@input.label, @input.id)

    if params[:options]
      options = {}
      params[:options].each_with_index do |option, index|
        options[make_guid(option, index)] = option if option.length > 0
      end
      @input.options = options
    end
    @input.save

    render json: @input
  end

  def destroy
    Input.find(params[:id]).destroy
    render json: {message: "Input deleted"}
  end


  private

  def input_params(params)
    params.require(:input).permit(:label, :required, :input_type, :media_type, :order, :options, :form_id)
  end

end
