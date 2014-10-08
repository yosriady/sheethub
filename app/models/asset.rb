class Asset < ActiveRecord::Base
  ASSET_HASH_SECRET = "sheethubhashsecret"

  belongs_to :sheet
  validates_presence_of :sheet

  has_attached_file :file,
                    :hash_secret => ASSET_HASH_SECRET #TODO: Use ENV for this
  # TODO: validate attachment content type: MIDI, .ptb, .gp5, .tg, etc...

  def s3_key
    # TODO: just remove domain, don't use magic numbers
    url[34..-1]
  end

end
