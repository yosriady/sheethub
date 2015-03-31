class APIKey < ActiveRecord::Base
  belongs_to :user
  before_validation :generate_token, on: :create

  validates :user, presence: true
  validates :token, presence: true

  private

  def generate_token
    begin
      self.token = SecureRandom.hex.to_s
    end while self.class.exists?(token: token)
  end
end
