class AddStatusToForms < ActiveRecord::Migration
  def change
    add_column :forms, :status, :string
    add_index :forms, :status
  end
end
