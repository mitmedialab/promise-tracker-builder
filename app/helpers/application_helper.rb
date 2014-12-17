module ApplicationHelper

  def format_survey_code(code)
    code.to_s.gsub(/(\d{3})(\d{3})/, '\1-\2')
  end
  
end
