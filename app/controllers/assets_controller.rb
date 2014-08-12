class AssetsController < ApplicationController

  def create
    @asset = Sheet.find(asset_params[:sheet_id]).assets.build(asset_params)
    @asset.save
    # Once created, render a create.js.erb file that adds a completed file HTML element to the view
  end

  private
    def set_asset
      @asset = Asset.find(params[:id])
    end

    def asset_params
      params.permit(:sheet_id, :url, :filename, :filesize, :filetype)
    end

end