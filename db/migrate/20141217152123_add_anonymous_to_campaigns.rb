class AddAnonymousToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :anonymous, :boolean
  end
end
