module Favoritable
  extend ActiveSupport::Concern

  included do
    acts_as_votable
  end

  def favorited_by(user)
    liked_by user
    SheetMailer.sheet_favorited_email(self, user).deliver
  end

  def unfavorited_by(user)
    unliked_by user
  end
end