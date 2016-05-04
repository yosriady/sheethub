class PagesController < ApplicationController
  def homepage
    track('View homepage')
    @instruments = Sheet.values_for_instruments
    @sheets = Sheet.is_public.includes(:user).order('created_at DESC').page(params[:page])
    @featured = Sheet.cached_most_liked.limit(3)
    @featured_users = User.featured
    @composers = Sheet.popular_composers
    @genres = Sheet.popular_genres
    @sources = Sheet.popular_sources
  end

  def features
    track('View features')
  end

  def notes
    track('View notes')
  end

  def support
    track('View support')
  end

  def terms
    track('View terms')
  end

  def privacy
    track('View privacy')
  end

  def community_guidelines
    track('View community guidelines')
  end

  def upgrade
    track('View upgrade page')
  end
end
