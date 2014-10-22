class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :sheet

  enum status: %w(completed canceled processing failed)
end
