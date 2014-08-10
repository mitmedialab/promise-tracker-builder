class RemoveStatusFromSurveys < ActiveRecord::Migration
  def change
    remove_column :surveys, :status, :string
  end
end
