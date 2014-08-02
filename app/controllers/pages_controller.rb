class PagesController < ApplicationController
  before_filter :disable_navbar, only: [:index]

  def index
  end

  def about
  end

  def terms
  end

  def privacy
  end

  private
    def disable_navbar
      @disable_navbar = true
    end

end
