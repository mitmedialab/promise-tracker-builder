class AddStateToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :state, :text
  end
end
