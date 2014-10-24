class Order < ActiveRecord::Base
  validates :sheet_id, uniqueness: { scope: :user_id,
                       message: "Users cannot have multiple orders of the same Sheet." }

  # TODO: validate only succesful orders can have null cart ids, else cart id must be present

  belongs_to :user
  belongs_to :sheet
  belongs_to :cart

  enum status: %w(processing completed failed)
end
