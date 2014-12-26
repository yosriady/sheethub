module Taggable
  extend ActiveSupport::Concern

  included do
    DEFAULT_NUM_POPULAR_TAGS = 10
  end

  class_methods do
    def popular_genres
      Rails.cache.fetch("popular_genres", expires_in: 1.day) do
        Sheet.tag_counts_on(:genres).order(taggings_count: :desc).limit(DEFAULT_NUM_POPULAR_TAGS)
      end
    end

    def popular_composers
      Rails.cache.fetch("popular_composers", expires_in: 1.day) do
        Sheet.tag_counts_on(:composers).order(taggings_count: :desc).limit(DEFAULT_NUM_POPULAR_TAGS)
      end
    end

    def popular_sources
      Rails.cache.fetch("popular_sources", expires_in: 1.day) do
        Sheet.tag_counts_on(:sources).order(taggings_count: :desc).limit(DEFAULT_NUM_POPULAR_TAGS)
      end
    end

  end
end
