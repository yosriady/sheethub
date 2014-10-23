class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :sheet
  belongs_to :cart

  enum status: %w(processing completed failed)
end
