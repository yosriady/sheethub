module SheetsHelper
  def cache_key_for_sheets
    count          = Sheet.count
    max_updated_at = Sheet.maximum(:updated_at).try(:utc).try(:to_s, :number)
  end
end