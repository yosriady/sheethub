module SheetsHelper
  def cache_key_for_sheets
    count          = Sheet.count
    max_updated_at = Sheet.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "sheets_#{count}_#{max_updated_at}"
  end

  def cache_key_for_sheet_tags(sheet)
    "sheet_tags_for_sheet_#{sheet.id}_#{sheet.updated_at}"
  end

  def cache_key_for_sheet_related_results(sheet)
    "sheet_related_results_for_sheet_#{@sheet.id}_#{@sheet.updated_at}"
  end
end
