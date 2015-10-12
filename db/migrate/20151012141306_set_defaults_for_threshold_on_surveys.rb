class SetDefaultsForThresholdOnSurveys < ActiveRecord::Migration
  def change
    change_column :surveys, :threshold_is_upper_limit, :boolean, default: true
  end
end
