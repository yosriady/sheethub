# Methods to find related objects (sheets and tags)
module Relatable
  extend ActiveSupport::Concern

  included do
    DEFAULT_NUM_RELATED_RESULTS = 3
  end

  def cache_key_for_related_sheets
    "related_sheets_to_sheet_#{id}_#{updated_at}"
  end

  def related_sheets(num_results = DEFAULT_NUM_RELATED_RESULTS)
    return [] if cached_joined_tags.empty?
    Rails.cache.fetch(cache_key_for_related_sheets, expires_in: 1.week) do
      Sheet.tagged_with(cached_joined_tags_list, any: true).limit(num_results)
    end
  end

  def cache_key_for_related_tags
    "related_tags_for_sheet_#{id}-#{updated_at}"
  end

  def related_tags
    Rails.cache.fetch(cache_key_for_related_tags, expires_in: 1.week) do
      related_tags = Set.new
      related_sheets.find_each { |sheet| related_tags.merge sheet.tag_objects }
      related_tags.to_a
    end
  end
end
