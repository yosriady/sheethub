class Sheet < ActiveRecord::Base
  attr_accessor :instruments_list # For form parsing
  enum difficulty: %w{ beginner intermediate advanced }
  bitmask :instruments, :as => [:guitar, :piano, :bass, :mandolin, :banjo, :ukulele, :violin, :flute, :harmonica, :trombone, :trumpet, :clarinet, :saxophone, :others], :null => false
  acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :composers, :genres, :origins

  has_attached_file :pdf,
                    :hash_secret => "sheethubhashsecret" #TODO: Use ENV for this
  validates_attachment_content_type :pdf,
      :content_type => [ 'application/pdf' ],
      :message => "Only pdf files are allowed"

  has_many :assets, :dependent => :destroy
  validates_associated :assets,
    :on => [:create, :update],
    :message => "Sheet supporting files invalid"

  default_scope { where(is_public?: true) }
  scope :is_public, -> { where(is_public?: true) }
  scope :is_private, -> { where(is_public?: false) }
  scope :free, -> { where(is_free?: true) }
  scope :original, -> { where(is_original?: true) }
  scope :flagged, -> { where(is_flagged?: true) }

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