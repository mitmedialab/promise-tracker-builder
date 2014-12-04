module SessionHelper
  def retrieve_access_token
    post api_v1_session_path({email: 'test@example.com', password: 'poor_password'})

    expect(response.response_code).to eq 201
    expect(response.body).to match(/"access_token":".{20}"/)
    parsed = JSON(response.body)
    parsed['access_token']['access_token'] # return token here!!
  end
end