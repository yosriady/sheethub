module SheetsHelper
  def cache_key_for_sheet_tags(sheet)
    "sheet_tags_for_sheet_#{sheet.id}_#{sheet.updated_at}"
  end

  def cache_key_for_sheet_related_results(sheet)
    "sheet_related_results_for_sheet_#{@sheet.id}_#{@sheet.updated_at}"
  end
end
