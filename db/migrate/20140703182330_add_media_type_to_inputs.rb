class AddMediaTypeToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :media_type, :string
  end
end
