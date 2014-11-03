class RemoveGuidFromInputs < ActiveRecord::Migration
  def change
    remove_column :inputs, :guid, :string
  end
end
