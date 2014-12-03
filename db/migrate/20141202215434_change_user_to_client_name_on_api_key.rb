class ChangeUserToClientNameOnApiKey < ActiveRecord::Migration
  def change
    rename_column :api_keys, :user, :client_name
    add_column :api_keys, :client_login_url, :string
  end
end
