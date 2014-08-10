class Sheet < ActiveRecord::Base
  attr_accessor :instruments_list # For form parsing
  enum difficulty: %w{ beginner intermediate advanced }
  bitmask :instruments, :as => [:guitar, :piano, :bass, :mandolin, :banjo, :ukulele, :violin, :flute, :harmonica, :trombone, :trumpet, :clarinet, :saxophone, :others], :null => false
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :composers, :genres, :sources

  has_attached_file :pdf,
                    :hash_secret => "sheethubhashsecret", #TODO: Use ENV for this
                    :default_url => "nil" #TODO: point to special Missing file route
  validates_attachment_content_type :pdf,
      :content_type => [ 'application/pdf' ],
      :message => "Only pdf files are allowed"

  has_many :assets, :dependent => :destroy
  accepts_nested_attributes_for :assets
  validates_associated :assets,
    :on => [:create, :update],
    :message => "Sheet supporting files invalid"

  default_scope { where(is_public?: true) }
  scope :is_public, -> { where(is_public?: true) }
  scope :is_private, -> { where(is_public?: false) }
  scope :free, -> { where(is_free?: true) }
  scope :original, -> { where(is_original?: true) }
  scope :flagged, -> { where(is_flagged?: true) }

  def price=(value)
    value > 0 ? write_attribute(:is_free?, false) : write_attribute(:is_free?, true)
    write_attribute(:price, value)
  end

  def related_sheets
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
    "
    Sheet.find_by_sql(sql)
  end

  def related_tags
    related_sheets = Sheet.tagged_with(joined_tags, :any => true).limit(5)
    related_tags = Set.new
    related_sheets.each{ |sheet| related_tags.merge sheet.tag_objects }
    related_tags.to_a
  end

  def self.instruments_to_bitmask(instruments)
    (instruments & Sheet.values_for_instruments).map { |r| 2**Sheet.values_for_instruments.index(r) }.inject(0, :+)
  end

  def joined_tags
    format_tags(tags)
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
      output = ""
      input.each do |tag|
        output << "'#{tag}',"
      end
      return output[0..-2] # Strip trailing comma
    end

end