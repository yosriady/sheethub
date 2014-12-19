module Deduplicatable
  extend ActiveSupport::Concern

  included do
    DEFAULT_PHASH_TRESHOLD = 5 # TODO: test out for ideal value
  end

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
end