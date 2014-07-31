class Sheet < ActiveRecord::Base
  before_validation :normalize_instruments

  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :composers, :genres, :series, :songs

  enum difficulty: %w{ beginner intermediate advanced }

  bitmask :instruments, :as => [:guitar, :piano, :bass, :mandolin, :banjo, :ukulele, :violin, :flute, :harmonica, :trombone, :trumpet, :clarinet, :saxophone, :others], :null => false

  def find_related
    sql = "
    SELECT sheets.*, COUNT(tags.id) AS count
    FROM sheets, tags, taggings
    WHERE (sheets.id != #{id}
           AND sheets.id = taggings.taggable_id
           AND taggings.taggable_type = 'Sheet'
           AND taggings.tag_id = tags.id
           AND tags.name IN (#{joined_tags}))
    GROUP BY sheets.id ORDER BY count DESC
    "
    Sheet.find_by_sql(sql)
  end

  private
    def joined_tags
      joined_tags = ""
      tag_list.each do |tag|
        joined_tags << "'#{tag}',"
      end
      return joined_tags[0..-2]
    end

    def normalize_instruments
      # @sheet.instruments
      # convert from comma separated string to symbol list
      binding.pry
    end

end