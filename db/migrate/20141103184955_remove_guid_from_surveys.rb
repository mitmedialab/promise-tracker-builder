class RemoveGuidFromSurveys < ActiveRecord::Migration
  def change
    remove_column :surveys, :guid, :string
  end
end
