# Class for SheetHub Notes
class Note < ActiveRecord::Base
  include Sluggable
  include Visible
  # TODO: include Taggable, Instrumentable, Favoritable

  belongs_to :user
  enum body_type: %w( vextab plaintext )

  validates :title, presence: true
  validates :body, presence: true
  validates :body_type, presence: true
end
