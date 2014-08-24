class Sheet < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sheet_slug, :use => :slugged

  def sheet_slug
    # TODO: ensure no collision with username or hash
    # See slug candidates section of link below
    # http://norman.github.io/friendly_id/file.Guide.html
    [
      :title
    ]
  end

  default_scope { where(is_public?: true) }
  default_scope { order(created_at: :desc) } # sort by most recent

  scope :is_public, -> { where(is_public?: true) }
  scope :is_private, -> { where(is_public?: false) }
  scope :free, -> { where(is_free?: true) }
  scope :original, -> { where(is_original?: true) }
  scope :flagged, -> { where(is_flagged?: true) }

  SORT_ORDERS = {"Most Recent"=>:newest, "Lowest Price"=>:lowest_price, "Highest Price"=>:highest_price}
  scope :lowest_price, -> { order(price: :asc)}
  scope :highest_price, -> { order(price: :desc)}
  scope :oldest, -> { order(created_at: :asc)}
  scope :newest, -> { order(created_at: :desc)}

  attr_accessor :instruments_list # For form parsing
  enum difficulty: %w{ beginner intermediate advanced }
  bitmask :instruments, :as => [:guitar, :piano, :bass, :mandolin, :banjo, :ukulele, :violin, :flute, :harmonica, :trombone, :trumpet, :clarinet, :saxophone, :others], :null => false
  acts_as_taggable
  acts_as_taggable_on :composers, :genres, :sources

  PDF_DEFAULT_URL = "nil"
  has_attached_file :pdf,
                    :styles => {:preview => ["", :jpg]},
                    :processors => [:preview],
                    :hash_secret => "sheethubhashsecret", #TODO: Use ENV for this
                    :default_url => PDF_DEFAULT_URL #TODO: point to special Missing file route
  validates_attachment_content_type :pdf,
      :content_type => [ 'application/pdf' ],
      :message => "Only pdf files are allowed"

  has_many :assets, :dependent => :destroy
  accepts_nested_attributes_for :assets
  validates_associated :assets,
    :on => [:create, :update],
    :message => "Sheet supporting files invalid"

  # Perceptual Hash methods
  DEFAULT_PHASH_TRESHOLD = 5 #TODO: test out for ideal value
  def duplicate?(sheet, treshold=DEFAULT_PHASH_TRESHOLD)
    if (pdf.present? && sheet.pdf.present?)
      this = Phashion::Image.new(pdf.url)
      other = Phashion::Image.new(sheet.pdf.url)
      this.duplicate?(other, treshold:treshold)
    end
  end

  def distance_from(sheet)
    if (pdf.present? && sheet.pdf.present?)
      this = Phashion::Image.new(pdf.url)
      other = Phashion::Image.new(sheet.pdf.url)
      this.distance_from(other)
    end
  end

  def fingerprint
    this = Phashion::Image.new(pdf.url)
    this.fingerprint
  end
  # END of phash methods

  def has_pdf_preview?
    Sheet.last.pdf.url(:preview) != PDF_DEFAULT_URL
  end

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

  def related_tags #TODO: optimize SQL querying with includes?
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