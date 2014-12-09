require 'spec_helper'

describe Api::V1::CampaignsController do
  let(:api_key) { FactoryGirl.create(:api_key) }
  let(:user) { FactoryGirl.create(:user, username: 'Username', password: 'Password') }
  before(:each) do
    @campaign = FactoryGirl.create(
      :campaign,
      title: 'Existing campaign',
      goal: 'Test goal',
      status: 'active',
      user_id: user.id
    )
  end

  describe 'Campaigns index endpoint' do

    context 'when using a valid API key' do

      it 'returns a list of campaigns' do
        get_with_token 'api/v1/campaigns', {}, api_key.access_token
        redirect_to api_v1_campaigns_path
        expect(response).to be_success
      end

      it 'does not list campaigns marked as "draft"' do
        draft_campaign_1 = FactoryGirl.create(:campaign, status: 'draft')
        draft_campaign_2 = FactoryGirl.create(:campaign, status: 'draft')

        get_with_token 'api/v1/campaigns', {}, api_key.access_token
        expect(response_body['payload'].length).to eq(1)
      end

    end

    context 'when not using an API key' do

      it 'restricts access to resources' do
        get 'api/v1/campaigns', {}, {}
        expect(response.status).to be(401)
      end
    end
  end

  describe 'Campaign show endpoint' do
    context 'when using a valid API key' do

      it 'returns a detailed view of campaign' do
        get_with_token "api/v1/campaigns/#{@campaign.id}", {}, api_key.access_token
        expect(response_body['payload']['id']).to eq(@campaign.id)
        expect(response_body['payload']['survey']['id']).to eq(@campaign.survey.id)
      end
    end

    context 'when not using an API key' do

      it 'restricts access to resources' do
        get "api/v1/campaigns/#{@campaign.id}", {}, {}
        expect(response.status).to be(401)
      end
    end
  end


  describe 'Campaign create endpoint' do

    context 'when using a valid API key' do
      let(:client_username) { 'test-api-user' }
      let(:client_user_id) { 10 }

      it 'restricts access if username and user_id not provided' do
        post_with_token 'api/v1/campaigns', {}, api_key.access_token
        expect(response.status).to eq(401)
      end

      it 'creates a new campaign if no campaign id provided' do
        params = {
          username: client_username,
          user_id: client_user_id
        }

        post_with_token 'api/v1/campaigns', params, api_key.access_token
        expect(Campaign.last.title).to be(nil)
      end

      it 'clones a campaign when campaign id provided' do
        params = {
          username: client_username,
          user_id: client_user_id,
          campaign_id: @campaign.id
        }

        post_with_token 'api/v1/campaigns', params, api_key.access_token
        api_user = User.where(api_client_user_id: client_user_id, api_client_name: api_key.client_name).first
        expect(api_user.campaigns.last.title).to eq(@campaign.title)
      end
    end

    context 'when not using an API key' do
      it 'restricts access to resources' do
        post 'api/v1/campaigns', {}, {}
        expect(response.status).to be(401)
      end
    end
  end

end