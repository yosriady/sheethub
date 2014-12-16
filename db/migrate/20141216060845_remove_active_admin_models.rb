class RemoveActiveAdminModels < ActiveRecord::Migration
  def change
    drop_table :active_admin_comments
    remove_index "active_admin_comments", ["author_type", "author_id"] if index_exists?("active_admin_comments", ["author_type", "author_id"])
    remove_index "active_admin_comments", ["namespace"] if index_exists?("active_admin_comments", ["namespace"])
    remove_index "active_admin_comments", ["resource_type", "resource_id"] if index_exists?("active_admin_comments", ["resource_type", "resource_id"])

    drop_table :admin_users
    remove_index "admin_users", ["email"] if index_exists?("admin_users", ["email"])
    remove_index "admin_users", ["reset_password_token"] if index_exists?("admin_users", ["reset_password_token"])

  end
end
