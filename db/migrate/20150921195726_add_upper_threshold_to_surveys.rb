class AddUpperThresholdToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :upper_threshold, :boolean
  end
end
