class PagesController < ApplicationController
  def support
    track('View features')
  end

  def faq
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
