# Methods to find related objects (sheets and tags)
module Relatable
  extend ActiveSupport::Concern

  included do
    DEFAULT_NUM_RELATED_RESULTS = 3
  end

  def related_sheets(num_results = DEFAULT_NUM_RELATED_RESULTS)
    return [] if joined_tags.empty?
    sql = "
    SELECT sheets.*, COUNT(tags.id) AS count
    FROM sheets, tags, taggings
    WHERE (sheets.id != #{id}
           AND sheets.id = taggings.taggable_id
           AND taggings.taggable_type = 'Sheet'
           AND taggings.tag_id = tags.id
           AND tags.name IN (#{joined_tags}))
    GROUP BY sheets.id ORDER BY count DESC
    LIMIT #{num_results}
    "
    Rails.cache.fetch('related_sheets_to_#{self}', expires_in: 1.day) do
      Sheet.find_by_sql(sql)
    end
  end

  def related_tags
    Rails.cache.fetch('related_tags_to_#{self}', expires_in: 1.day) do
      related_tags = Set.new
      related_sheets_via_tags.find_each { |sheet| related_tags.merge sheet.tag_objects }
      related_tags.to_a
    end
  end

  def related_sheets_via_tags
    Rails.cache.fetch('related_sheets_via_tags_to_#{self}', expires_in: 1.day) do
      Sheet.tagged_with(joined_tags, any: true).includes(:sources, :composers, :genres).limit(5)
    end
  end
end
