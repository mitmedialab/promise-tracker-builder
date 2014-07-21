class AddAnnotateToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :annotate, :boolean
  end
end
