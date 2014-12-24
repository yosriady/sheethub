class PagesController < ApplicationController
  def faq
    track('View features')
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
end
