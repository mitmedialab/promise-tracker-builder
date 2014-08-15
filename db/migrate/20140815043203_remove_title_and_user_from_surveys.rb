class RemoveTitleAndUserFromSurveys < ActiveRecord::Migration
  def change
    remove_column :surveys, :title, :text
    remove_reference :surveys, :user, index: true
  end
end
