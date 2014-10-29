class Sheet < ActiveRecord::Base
  SHEET_HASH_SECRET = "sheethubhashsecret"
  PDF_DEFAULT_URL = "nil"
  SORT_ORDERS = {"Most Recent"=>:latest, "Least Recent"=>:oldest, "Lowest Price"=>:lowest_price, "Highest Price"=>:highest_price}
  DEFAULT_PHASH_TRESHOLD = 5 #TODO: test out for ideal value
  EXPIRATION_TIME = 600
  PRICE_VALUE_VALIDATION_MESSAGE = "Price must be between $1.99 - $999.99"
  INVALID_ASSETS_MESSAGE = "Sheet supporting files invalid"
  INVALID_SORT_ORDERS_MESSAGE = "Sort Order not in #{Sheet::SORT_ORDERS.values}"

  validates :price_cents, inclusion: { in: (0..99999),
    message: PRICE_VALUE_VALIDATION_MESSAGE }
  belongs_to :user
  acts_as_votable
  acts_as_paranoid
  before_destroy :soft_destroy_callback
  searchkick word_start: [:name]
  extend FriendlyId
  friendly_id :sheet_slug, :use => :slugged
  validates :title, presence: true
  validates :publishing_right, presence: true
  has_many :flags, :dependent => :destroy

  scope :is_public, -> { where(is_public: true) }
  scope :is_private, -> { where(is_public: false) }
  scope :free, -> { where(is_free: true) }
  scope :original, -> { where(is_original: true) }
  scope :flagged, -> { where(is_flagged: true) }

  scope :lowest_price, -> { order(price_cents: :asc)}
  scope :highest_price, -> { order(price_cents: :desc)}
  scope :oldest, -> { order(created_at: :asc)}
  scope :latest, -> { order(created_at: :desc)}

  attr_accessor :instruments_list # For form parsing
  enum difficulty: %w{ beginner intermediate advanced }
  enum publishing_right: %w{original rights public_domain}
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
      :content_type => [ 'application/pdf' ],
      :message => "Only pdf files are allowed"
  # do_not_validate_attachment_file_type :pdf
  validates :pdf, presence: true

  has_many :assets, :dependent => :destroy
  accepts_nested_attributes_for :assets
  validates_associated :assets,
    :on => [:create, :update],
    :message => INVALID_ASSETS_MESSAGE

  def rights
    return "Original Work" if original?
    return "With Publishing Rights" if rights?
    return "Public Domain Work" if public_domain?
  end

  def purchased_by?(user)
    return false unless user
    user.purchased_sheet_ids.include?(id)
  end

  def uploaded_by?(usr)
    return false unless usr
    user.id == usr.id
  end

  def total_sales
    total_sold * price
  end

  def total_sold
    Order.where(sheet_id: id).size
  end

  def total_royalties
    Order.where(sheet_id: id).size * royalty
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

  def self.sorted(sort_order)
    if sort_order.nil?
      self.send(:latest)
    elsif SORT_ORDERS.values.include?(sort_order.to_sym)
      self.send(sort_order)
    else
      raise INVALID_SORT_ORDERS_MESSAGE
    end
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

  def has_playable
    get_audio_assets.present?
  end

  def get_audio_assets
    assets.select{|asset| asset.filetype.starts_with? "audio"}
  end

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

  # TODO: currently related_sheets is limited to 4 results for performance, refactor with ElasticSearch
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
    LIMIT 4
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

end