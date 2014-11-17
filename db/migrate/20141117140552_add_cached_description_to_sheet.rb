class AddCachedDescriptionToSheet < ActiveRecord::Migration
  def change
    add_column :sheets, :description_html, :text
  end
end
