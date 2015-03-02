module Visible
  extend ActiveSupport::Concern

  included do
    validates :visibility, presence: true
    scope :is_public, -> { where(visibility: Sheet.visibilities[:vpublic]) }
    scope :is_private, -> { where(visibility: Sheet.visibilities[:vprivate]) }
    enum visibility: %w( vpublic vprivate ) # We use vpublic because public is a reserved keyword.
  end

  def publicly_visible?
    vpublic?
  end

  def privately_visible?
    vprivate?
  end

  def visibility_string
    visibility[1..-1].titleize
  end

end