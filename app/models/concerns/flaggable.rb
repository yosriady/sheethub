module Flaggable
  extend ActiveSupport::Concern

  included do
      has_many :flags, dependent: :destroy
      scope :flagged, -> { where(is_flagged: true) }
  end
end