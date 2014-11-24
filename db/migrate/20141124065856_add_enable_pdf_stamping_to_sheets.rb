class AddEnablePdfStampingToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :enable_pdf_stamping, :boolean, default: true
  end
end
