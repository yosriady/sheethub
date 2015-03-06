module Likable
  extend ActiveSupport::Concern

  included do
    acts_as_votable
  end

  def liked_by(user)
    super(user)
    SheetMailer.sheet_liked_email(self, user).deliver
  end

  def unliked_by(user)
    super(user)
  end
end