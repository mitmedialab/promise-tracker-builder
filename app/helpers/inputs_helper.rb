module InputsHelper

  def render_xml(input)
    if input.input_type == "binary" || input.input_type == "select1" || input.input_type == "select"
      render partial: "inputs/#{input.input_type}", locals: {input: input}
    else
      render partial: "inputs/text", locals: {input: input}
    end
  end

end
