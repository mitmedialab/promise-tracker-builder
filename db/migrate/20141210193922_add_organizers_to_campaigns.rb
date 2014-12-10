class AddOrganizersToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :organizers, :text
  end
end
