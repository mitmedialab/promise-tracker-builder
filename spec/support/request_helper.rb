module RequestHelper
  def get_with_token(url, params, token)
    get url, params, { 'HTTP_AUTHORIZATION' => "Token token=#{token}" }
  end

  def post_with_token(url, params, token)
    post url, params, { 'HTTP_AUTHORIZATION' => "Token token=#{token}" }
  end
end