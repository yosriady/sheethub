module Sluggable
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    def should_generate_new_friendly_id?
      title_changed?
    end
  end

  def slug_candidates
    [
      :title,
      [:title, user.username]
    ]
  end
end