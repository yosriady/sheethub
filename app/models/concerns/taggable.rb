module Taggable
  extend ActiveSupport::Concern

  included do
    DEFAULT_NUM_POPULAR_TAGS = 10
    MAX_NUMBER_OF_TAGS = 5
    TOO_MANY_TAGS_MESSAGE = 'You have too many tags. Each sheet can have up to 5 of each: genres, composers, sources.'

    acts_as_taggable
    acts_as_taggable_on :composers, :genres, :sources, :publishers
    validate :validate_number_of_tags
    after_save :cache_tags
  end

  class_methods do
    def tags
      Rails.cache.fetch("all_tags", expires_in: 1.day) do
        Sheet.all_tags
      end
    end

    [:genres, :composers, :sources].each do |category|
      define_method("popular_#{category}") do
        Rails.cache.fetch("popular_#{category}", expires_in: 1.day) do
          Sheet.tag_counts_on(category).order(taggings_count: :desc).limit(DEFAULT_NUM_POPULAR_TAGS)
        end
      end
    end
  end

  def clear_tags
    # TODO: refactor this
    genres.clear
    sources.clear
    composers.clear
    publishers.clear
  end

  def restore_tags
    self.genre_list = self.cached_genres
    self.source_list = self.cached_sources
    self.composer_list = self.cached_composers
    self.publisher_list = self.cached_publishers.split(", ").map(&:parameterize)
    self.save!
  end

  def cache_tags
    composer_tag_list = composers.pluck(:name)
    source_tag_list = sources.pluck(:name)
    genre_tag_list = genres.pluck(:name)
    publisher_string = publishers.to_a.map(&:name).map(&:titleize).join(", ")
    self.update_columns(cached_composers: composer_tag_list,
                cached_sources: source_tag_list,
                cached_genres: genre_tag_list,
                cached_publishers: publisher_string,
                cached_joined_tags: [instruments, composer_tag_list, source_tag_list, genre_tag_list].flatten)
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
