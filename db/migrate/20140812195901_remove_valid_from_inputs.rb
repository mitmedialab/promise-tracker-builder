class RemoveValidFromInputs < ActiveRecord::Migration
  def change
    remove_column :inputs, :is_valid
  end
end
