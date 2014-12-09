require 'spec_helper'

describe Api::V1::UsersController do
  let(:api_key) { FactoryGirl.create(:api_key) }

  describe 'Sign in endpoint' do
    context 'when using a valid API key' do

      it 'restricts access if username and user_id not provided' do
        post_with_token '/api/v1/users/sign_in', {}, api_key.access_token
        expect(response.status).to eq(401)
      end

      it "creates a user account if a matching one doesn't exist" do
        params = {
          username: "new-user",
          user_id: 8
        }

        post_with_token '/api/v1/users/sign_in', params, api_key.access_token
        expect(User.where(api_client_name: api_key.client_name, api_client_user_id: params[:user_id]).length).to eq(1)
      end

      it 'logs in user if user exists' do
        user = FactoryGirl.create(
          :user, 
          username: "existing-user",
          password: "password",
          api_client_user_id: 8, 
          api_client_name: api_key.client_name
        )

        params = {
          username: "existing-user",
          user_id: 8
        }

        post_with_token '/api/v1/users/sign_in', params, api_key.access_token
        expect(User.where(api_client_name: api_key.client_name, api_client_user_id: params[:user_id]).length).to eq(1)
        expect(response).to redirect_to campaigns_path
      end
    end

    context 'when not using an API key' do
      it 'restricts access' do
        post 'api/v1/users/sign_in', {}, {}
        expect(response.status).to be(401)
      end
    end
  end
end