class Survey < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :inputs
  before_create :generate_code

  def activate(status)
    uri = URI(ENV['AGGREGATOR_URL'] + "/surveys/#{status}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json', 'Authorization' => ENV['AGGREGATOR_ACCESS_KEY']})
    request.body = self.to_json(
      only: [:id, :code, :title, :campaign_id],
      include: { inputs: { only: [:id, :label, :input_type, :order, :options, :required] }}
    )

    begin
      response = http.request(request)
      data = JSON.parse(response.body)

      if data['status'] == 'success'
        self.campaign.update_attributes(
          status: status,
          start_date: data['payload']['start_date'].to_datetime
        )
      end

      data
    rescue Errno::ECONNREFUSED
      { status: "error" }
    end
  end

  def close
    uri = URI(ENV['AGGREGATOR_URL'] + "surveys/#{self.code}/close")
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
    uri = URI(ENV['AGGREGATOR_URL'] + "surveys/#{self.id}/responses")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request)
    JSON.parse(response.body)['payload'] || []
  end

  def generate_code
    begin
      self.code = rand(899999) + 100000
    end while self.class.exists?(code: code)
  end

end
