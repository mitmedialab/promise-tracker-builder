class AddUidToForms < ActiveRecord::Migration
  def change
    add_column :forms, :uid, :string
  end
end
