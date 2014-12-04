require 'spec_helper'

describe 'Campaigns API' do
  let(:api_key) { FactoryGirl.create(:api_key) }
  before(:each) { FactoryGirl.create(:campaign, status: 'active') }

  context 'when using a valid API key' do

    it 'returns a list of campaigns' do
      get 'api/v1/campaigns', {}, {'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}"}
      expect(response).to be_success
    end

    it 'does not list campaigns marked as "draft"' do
      draft_campaign_1 = FactoryGirl.create(:campaign, status: 'draft')
      draft_campaign_2 = FactoryGirl.create(:campaign, status: 'draft')

      get 'api/v1/campaigns', {}, {'HTTP_AUTHORIZATION' => "Token token=#{api_key.access_token}"}
      expect(JSON.parse(response.body)["payload"].length).to eq(1)
    end

  end
  
end