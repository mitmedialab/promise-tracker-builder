class AddUserToForms < ActiveRecord::Migration
  def change
    add_reference :forms, :user, index: true
  end
end
