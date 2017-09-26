module ApplicationHelper

  def format_survey_code(code)
    code.to_s.gsub(/(\d{3})(\d{3})/, '\1-\2')
  end

  def asset_url(asset)
    "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end
  
end
