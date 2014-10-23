class Order < ActiveRecord::Base
  validates :sheet_id, uniqueness: { scope: :user_id,
                       message: "Users cannot have multiple orders of the same Sheet." }

  belongs_to :user
  belongs_to :sheet
  belongs_to :cart

  enum status: %w(processing completed failed)
end
