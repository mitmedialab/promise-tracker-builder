class AddGuidToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :guid, :string
  end
end
