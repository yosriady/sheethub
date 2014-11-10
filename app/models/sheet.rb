class Sheet < ActiveRecord::Base
  SHEET_HASH_SECRET = "sheethubhashsecret"
  PDF_DEFAULT_URL = "nil"
  DEFAULT_PHASH_TRESHOLD = 5 #TODO: test out for ideal value
  EXPIRATION_TIME = 600
  PRICE_VALUE_VALIDATION_MESSAGE = "Price must be either $0 or between $1.99 - $999.99"
  INVALID_ASSETS_MESSAGE = "Sheet supporting files invalid"
  MAX_FILESIZE = 20

  before_create :record_publisher
  validate :validate_price
  belongs_to :user
  acts_as_votable
  acts_as_paranoid
  before_destroy :soft_destroy_callback
  searchkick word_start: [:name]
  extend FriendlyId
  friendly_id :sheet_slug, :use => :slugged
  validates :title, presence: true
  validates :license, presence: true
  has_many :flags, :dependent => :destroy

  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }
  scope :flagged, -> { where(is_flagged: true) }
  scope :best_sellers, -> { is_public.order(price_cents: :desc)}

  attr_accessor :instruments_list # For form parsing
  enum difficulty: %w{ beginner intermediate advanced }
  enum license: %w{all_rights_reserved creative_commons cc0 public_domain}
  bitmask :instruments, :as => [:guitar, :piano, :bass, :mandolin, :banjo, :ukulele, :violin, :flute, :harmonica, :trombone, :trumpet, :clarinet, :saxophone, :others], :null => false
  validates :instruments, presence: true
  acts_as_taggable
  acts_as_taggable_on :composers, :genres, :sources

  has_attached_file :pdf,
                    :styles => {
                      # :watermark => {},
                      :preview => {:geometry => "", :format => :png}
                    },
                    :processors => [:preview], # :watermark currently disabled
                    :hash_secret => SHEET_HASH_SECRET, #TODO: Use ENV for this
                    :default_url => PDF_DEFAULT_URL, #TODO: point to special Missing file route
                    :preserve_files => "true"
  validates_attachment_content_type :pdf,
      :content_type => [ 'application/pdf' ]
  validates_attachment_size :pdf, :in => 0.megabytes..MAX_FILESIZE.megabytes
  validates :pdf, presence: true

  has_many :assets, :dependent => :destroy
  accepts_nested_attributes_for :assets
  validates_associated :assets,
    :on => [:create, :update],
    :message => INVALID_ASSETS_MESSAGE

  def verbose_license
    return "All rights reserved" if all_rights_reserved?
    return "Creative Commons" if creative_commons?
    return "CC0" if cc0?
    return "Public Domain" if public_domain?
  end

  def purchased_by?(user)
    return false unless user
    return user.purchased?(id)
  end

  def uploaded_by?(usr)
    return false unless usr
    user.id == usr.id
  end

  def total_sales
    completed_orders.size * price
  end

  def total_earnings
    completed_orders.size * royalty
  end

  def completed_orders
    Order.where(sheet_id: id, status: Order.statuses[:completed])
  end

  def price
    return price_cents.to_f / 100
  end

  def royalty
    return ((0.8 * price) - 0.8).round(1)
  end

  def is_free?
    return price_cents == 0
  end

  def sheet_slug
    [
      :title,
      [:title, user.username]
    ]
  end

  # Perceptual Hash methods
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
    preview_url = pdf_preview_url
    preview_url.present? && preview_url != PDF_DEFAULT_URL
  end

  def pdf_preview_url
    pdf.expiring_url(EXPIRATION_TIME, :preview)
  end

  def pdf_download_url
    pdf.expiring_url(EXPIRATION_TIME)
  end

  # TODO: currently related_sheets is limited to 3 results for performance, refactor with ElasticSearch
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
    LIMIT 3
    "
    Sheet.find_by_sql(sql)
  end

  def related_tags
    related_sheets = Sheet.tagged_with(joined_tags, :any => true).includes(:sources, :composers, :genres).limit(5)
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
    def soft_destroy_callback
      # TODO: Send email to all buyers
    end

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

    def validate_price
      valid_price = price_cents.zero? || price_cents.in?(199..99999)
      errors.add(:price_cents, PRICE_VALUE_VALIDATION_MESSAGE) unless valid_price
    end

    def record_publisher
      user.update_attribute(:has_published, true) unless user.has_published
    end
end