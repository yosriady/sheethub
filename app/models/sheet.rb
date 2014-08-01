class Sheet < ActiveRecord::Base
  attr_accessor :instruments_list # For form parsing

  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :composers, :genres, :origins

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

  def self.instruments_to_bitmask(instruments)
    (instruments & Sheet.values_for_instruments).map { |r| 2**Sheet.values_for_instruments.index(r) }.inject(0, :+)
  end

  private
    def joined_tags
      joined_tags = ""
      tag_list.each do |tag|
        joined_tags << "'#{tag}',"
      end
      return joined_tags[0..-2]
    end

end