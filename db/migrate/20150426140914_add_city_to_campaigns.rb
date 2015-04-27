class AddCityToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :city, :text
  end
end
