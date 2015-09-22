class AddSensorTypeToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :sensor_type, :text
    add_column :surveys, :threshold, :float
  end
end
