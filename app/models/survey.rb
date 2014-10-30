class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :inputs

  AGGREGATOR_URL = 'http://dev.aggregate.promisetracker.org/surveys'

  def activate
    uri = URI(AGGREGATOR_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    request.body = self.to_json(
      only: [:id, :title, :campaign_id],
      include: { inputs: { only: [:id, :label, :input_type, :order, :options] }}
    )
    binding.pry
    response = http.request(request)
    JSON.parse(response.body)
  end

  def close
    uri = URI(AGGREGATOR_URL + '/' + self.id.to_s + '/close')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Put.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request)
    JSON.parse(response.body)
  end

end
