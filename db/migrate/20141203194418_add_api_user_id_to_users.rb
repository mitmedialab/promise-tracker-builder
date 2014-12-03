class AddApiUserIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_client_user_id, :integer
  end
end
