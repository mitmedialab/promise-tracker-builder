require 'spec_helper'

describe Api::V1::CampaignsController do
  let(:api_key) { FactoryGirl.create(:api_key) }

  describe 'Campaigns index endpoint' do

    context 'when using a valid API key' do
      before(:each) { FactoryGirl.create(:campaign, status: 'active') }

      it 'returns a list of campaigns' do
        get_with_token 'api/v1/campaigns', {}, api_key.access_token
        expect(response).to be_success
      end

      it 'does not list campaigns marked as "draft"' do
        draft_campaign_1 = FactoryGirl.create(:campaign, status: 'draft')
        draft_campaign_2 = FactoryGirl.create(:campaign, status: 'draft')

        get_with_token 'api/v1/campaigns', {}, api_key.access_token
        expect(JSON.parse(response.body)["payload"].length).to eq(1)
      end

    end

    context 'when not using an API key' do

      it 'restricts access to resources' do
        get 'api/v1/campaigns', {}, {}
        expect(response.status).to be(401)
      end
    end
  end


  describe 'Campaign create endpoint' do

    context 'when using a valid API key' do
      let(:username) { 'test-api-user' }
      let(:user_id) { 10 }
      let(:user) { FactoryGirl.create(:user, username: 'Username', password: 'Password') }

      it 'restricts access if username and user_id not provided' do
        post_with_token 'api/v1/campaigns', {}, api_key.access_token
        expect(response.status).to eq(401)
      end

      it 'creates a new campaign if no campaign id provided' do
        params = {
          username: username,
          user_id: user_id
        }

        post_with_token 'api/v1/campaigns', params, api_key.access_token
        expect(Campaign.all.length).to eq(1)
      end

      it 'clones a campaign when campaign id provided' do
        campaign = FactoryGirl.create(
          :campaign,
          title: 'Existing campaign',
          goal: 'Campaign goal',
          user_id: user.id
        )

        params = {
          username: username,
          user_id: user_id,
          campaign_id: campaign.id
        }

        post_with_token 'api/v1/campaigns', params, api_key.access_token
        api_user = User.where(api_client_user_id: user_id, api_client_name: api_key.client_name).first
        expect(api_user.campaigns.last.goal).to eq(campaign.goal)
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