module Likable
  extend ActiveSupport::Concern

  included do
    acts_as_votable
    scope :most_liked, -> { is_public.order(cached_votes_up: :desc) }
  end

  class_methods do
    def cached_most_liked
      Rails.cache.fetch('most_liked', expires_in: 1.day) do
        Sheet.includes(:user).most_liked
      end
    end
  end

  def liked_by(user)
    super(user)
    SheetMailer.sheet_liked_email(self, user).deliver
  end

  def unliked_by(user)
    super(user)
  end
end