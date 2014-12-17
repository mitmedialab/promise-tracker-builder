class AddCodeToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :code, :integer
  end
end
