class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.text :title

      t.timestamps
    end
  end
end
