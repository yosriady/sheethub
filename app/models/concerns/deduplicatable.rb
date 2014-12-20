# Methods for authomatic copyright infringement detection
module Deduplicatable
  extend ActiveSupport::Concern

  included do
    DEFAULT_PHASH_TRESHOLD = 5 # TODO: test out for ideal value
  end

  def duplicate?(sheet, treshold = DEFAULT_PHASH_TRESHOLD)
    return unless pdf.present? && sheet.pdf.present?
    this = Phashion::Image.new(pdf.url)
    other = Phashion::Image.new(sheet.pdf.url)
    this.duplicate?(other, treshold: treshold)
  end

  def distance_from(sheet)
    return unless pdf.present? && sheet.pdf.present?
    this = Phashion::Image.new(pdf.url)
    other = Phashion::Image.new(sheet.pdf.url)
    this.distance_from(other)
  end

  def fingerprint
    this = Phashion::Image.new(pdf.url)
    this.fingerprint
  end
end
