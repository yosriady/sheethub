class PagesController < ApplicationController
  before_filter :disable_navbar, only: [:index]

  def index
    track('View homepage')
  end

  def faq
    track('View help')
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

  private
    def disable_navbar
      @disable_navbar = true
    end

end
