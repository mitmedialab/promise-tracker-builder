class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :inputs

  AGGREGATOR_URL = 'http://dev.aggregate.promisetracker.org/surveys'

  def activate(status)
    uri = URI(AGGREGATOR_URL + "/#{status}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    request.body = self.to_json(
      only: [:id, :title, :campaign_id],
      include: { inputs: { only: [:id, :label, :input_type, :order, :options, :required] }}
    )
    response = http.request(request)
    payload = JSON.parse(response.body)

    if payload['status'] == 'success'
      self.campaign.update_attribute(:status, status)
    end

    payload
  end

  def close
    uri = URI(AGGREGATOR_URL + '/' + self.id.to_s + '/close')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Put.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request)
    JSON.parse(response.body)
  end

  def clone
    clone = self.dup
    self.inputs.each do |input|
      clone.inputs << input.dup
    end
    clone
  end

  def get_responses
    uri = URI(AGGREGATOR_URL + '/' + self.id.to_s + '/responses')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request)
    JSON.parse(response.body)['payload'] || []
  end

end
