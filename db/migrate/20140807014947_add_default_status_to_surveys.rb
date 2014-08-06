class AddDefaultStatusToSurveys < ActiveRecord::Migration
  def change
    change_column :surveys, :status, :string, default: 'draft'
  end
end
