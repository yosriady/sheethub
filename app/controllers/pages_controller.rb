class PagesController < ApplicationController
  before_filter :disable_navbar, only: [:index]

  def index
  end

  def faq
  end

  def terms
  end

  def privacy
  end

  def upgrade
  end

  private
    def disable_navbar
      @disable_navbar = true
    end

end
