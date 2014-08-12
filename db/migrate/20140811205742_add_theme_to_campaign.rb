class AddThemeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :theme, :string
  end
end
