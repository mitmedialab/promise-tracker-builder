class AddValidToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :is_valid, :boolean
  end
end
