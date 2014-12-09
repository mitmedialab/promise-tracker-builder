module RequestHelper
  def get_with_token(url, params, token)
    get url, params.merge!({format: 'json'}), { 'HTTP_AUTHORIZATION' => "Token token=#{token}" }
  end

  def post_with_token(url, params, token)
    post url, params.merge!({format: 'json'}), { 'HTTP_AUTHORIZATION' => "Token token=#{token}" }
  end

  def response_body
    JSON.parse(response.body)
  end
end