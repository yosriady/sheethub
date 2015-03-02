class Note < ActiveRecord::Base
  include Sluggable
  include Visible
  # TODO: include Taggable, Instrumentable, Favoritable

  belongs_to :user
  enum type: %w( plaintext vextab )
end
