class RemoveMediaTypeFromInputs < ActiveRecord::Migration
  def change
    remove_column :inputs, :media_type, :string
  end
end
