class AddFileToAssets < ActiveRecord::Migration
  def self.up
    add_attachment :assets, :file
  end

  def self.down
    remove_attachment :assets, :file
  end
end
