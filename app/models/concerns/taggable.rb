module Taggable
  extend ActiveSupport::Concern

  included do
    DEFAULT_NUM_POPULAR_TAGS = 10
    TOO_MANY_TAGS_MESSAGE = 'You have too many tags. Each sheet can have up to 5 of each: genres, composers, sources.'

    acts_as_taggable
    acts_as_taggable_on :composers, :genres, :sources
    validate :validate_number_of_tags
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

  def clear_tags
    # TODO: refactor this
    genres.clear
    sources.clear
    composers.clear
  end

  def restore_tags
    self.genre_list = self.cached_genres
    self.source_list = self.cached_sources
    self.composer_list = self.cached_composers
    self.save!
  end

  def composer_list=(tag_list=[])
    super
    tag_list.map!(&:downcase)
    self.cached_composers = tag_list
    self.cached_joined_tags = [instruments, genre_list, source_list, tag_list].flatten
  end

  def genre_list=(tag_list=[])
    super
    tag_list.map(&:downcase)
    self.cached_genres = tag_list
    self.cached_joined_tags = [instruments, composer_list, source_list, tag_list].flatten
  end

  def source_list=(tag_list=[])
    super
    tag_list.map(&:downcase)
    self.cached_sources = tag_list
    self.cached_joined_tags = [instruments, genre_list, composer_list, tag_list].flatten
  end

  protected

  def tags
    [genre_list, composer_list, source_list].flatten
  end

  def tag_objects
    [genres, composers, sources].flatten
  end

  # Formatting method for selectize.js usage
  def format_tags(input)
    output = ''
    input.each do |tag|
      output << "'#{tag}',"
    end
    output[0..-2] # Strip trailing comma
  end

  def validate_number_of_tags
    valid_number = genre_list.size <= MAX_NUMBER_OF_TAGS && source_list.size <= MAX_NUMBER_OF_TAGS && composer_list.size <= MAX_NUMBER_OF_TAGS
    errors.add(:tags, TOO_MANY_TAGS_MESSAGE) unless valid_number
  end
end
