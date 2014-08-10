class AssetsController < ApplicationController

  def create
    binding.pry
    @asset = Asset.create(asset_params)
    # Once created, render a create.js.erb file that adds a completed file HTML element to the view
  end

  private
    def asset_params
      params.require(:asset).permit(:direct_upload_url)
    end

end