class AddCaseInsensitiveUniqueUsernameIndexToUser < ActiveRecord::Migration
  def up
    remove_index :users, :username
    execute "CREATE UNIQUE INDEX index_users_on_lowercase_username
             ON users USING btree (lower(username));"
  end

  def down
    execute "DROP INDEX index_users_on_lowercase_username;"
    add_index :users, :username, :unique => true
  end
end