class AddCampaignPageValidToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :campaign_page_valid, :boolean
  end
end
