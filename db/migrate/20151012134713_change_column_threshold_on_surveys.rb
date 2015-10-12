class ChangeColumnThresholdOnSurveys < ActiveRecord::Migration
  def change
    rename_column :surveys, :upper_threshold, :threshold_is_upper_limit
  end
end
