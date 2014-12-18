class ChangePdfStampingDefaultForSheets < ActiveRecord::Migration
  def change
    change_column_default :sheets, :enable_pdf_stamping, false
  end
end
