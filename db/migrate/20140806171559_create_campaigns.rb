class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :title
      t.text :goal
      t.integer :submissions_target
      t.text :audience
      t.text :data_collectors
      t.string :status, default: 'draft'
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
