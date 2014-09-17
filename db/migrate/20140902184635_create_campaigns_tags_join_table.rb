class CreateCampaignsTagsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :campaigns, :tags do |t|
      t.index :campaign_id
      t.index :tag_id
    end
  end
end
