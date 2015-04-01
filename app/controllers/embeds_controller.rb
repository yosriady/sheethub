class EmbedsController < ApplicationController
  layout "embed"

  def sheet
    @sheet = Sheet.friendly.find(params[:id])
  end

end
