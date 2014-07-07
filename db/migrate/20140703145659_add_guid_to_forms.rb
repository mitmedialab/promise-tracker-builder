class AddGuidToForms < ActiveRecord::Migration
  def change
    add_column :forms, :guid, :string
  end
end
