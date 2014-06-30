class CreateInputs < ActiveRecord::Migration
  def change
    create_table :inputs do |t|
      t.text :label
      t.text :input_type
      t.boolean :required
      t.integer :order
      t.text :options
      t.references :form

      t.timestamps
    end
  end
end
