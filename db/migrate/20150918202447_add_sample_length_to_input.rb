class AddSampleLengthToInput < ActiveRecord::Migration
  def change
    add_column :inputs, :sample_length, :integer
  end
end
