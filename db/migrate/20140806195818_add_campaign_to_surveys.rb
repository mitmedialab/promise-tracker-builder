class AddCampaignToSurveys < ActiveRecord::Migration
  def change
    add_reference :surveys, :campaign, index: true
  end
end
