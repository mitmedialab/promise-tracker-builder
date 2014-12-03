class AddApiClientNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_client_name, :string, default: ""
  end
end
