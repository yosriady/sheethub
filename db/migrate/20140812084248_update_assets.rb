class UpdateAssets < ActiveRecord::Migration
  def change
    add_column :assets, :url, :string
    remove_column :assets, :file_updated_at
    rename_column :assets, :file_file_name, :filename
    rename_column :assets, :file_content_type, :filetype
    rename_column :assets, :file_file_size, :filesize
  end
end
