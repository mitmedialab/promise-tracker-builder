json.status "success"
json.payload do
  json.(@campaign, :id, :title, :description, :goal, :data_collectors, :status, :tags)
  
  json.tags do
    json.array! @campaign.tags.collect {|t| t.label}
  end

  json.survey do
    json.(@campaign.survey, :id, :title)
    json.inputs(@campaign.survey.inputs, :id, :label, :input_type, :options)
  end

  json.public_url "#{request.protocol}#{request.host}/campaigns/#{@campaign.id}/share"
end