class RenameFormsToSurveys < ActiveRecord::Migration
  def change
    rename_table :forms, :surveys
    rename_column :inputs, :form_id, :survey_id
  end
end
