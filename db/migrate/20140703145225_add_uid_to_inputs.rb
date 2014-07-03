class AddUidToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :uid, :string
  end
end
