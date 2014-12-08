json.status "success"
json.payload do
  json.array! @campaigns do |campaign|
    json.(campaign, :id, :title, :description, :status, :tags)

    json.tags do
      json.array! campaign.tags.collect {|t| t.label}
    end

    json.public_url "#{request.protocol}#{request.host}/campaigns/#{campaign.id}/share"
  end
end