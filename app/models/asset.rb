class Asset < ActiveRecord::Base
  belongs_to :sheet

  has_attached_file :file,
                    :hash_secret => "sheethubhashsecret" #TODO: Use ENV for this
  # TODO: validate attachment content type: MIDI, .ptb, .gp5, .tg, etc...

end
