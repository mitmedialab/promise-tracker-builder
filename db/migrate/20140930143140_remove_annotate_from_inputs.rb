class RemoveAnnotateFromInputs < ActiveRecord::Migration
  def change
    remove_column :inputs, :annotate, :boolean
  end
end
