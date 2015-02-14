module Pricable
  extend ActiveSupport::Concern

  included do
    MIN_PRICE = 99
    MAX_PRICE = 999_99
    PRICE_VALUE_VALIDATION_MESSAGE = 'Price must be either $0 or between $0.99 - $999.99'
    validate :validate_price
  end

  def price
    price_cents.to_f / 100
  end

  def price=(val)
    write_attribute :price_cents, (val.to_f * 100).to_i
  end

  def free?
    price_cents.zero?
  end

  protected

  def validate_price
    valid_price = price_cents.zero? || price_cents.in?(MIN_PRICE..MAX_PRICE)
    errors.add(:price, PRICE_VALUE_VALIDATION_MESSAGE) unless valid_price
  end

end