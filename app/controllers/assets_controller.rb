class AssetsController < ApplicationController
  before_action :set_asset, only: [:destroy]

  def create
    @asset = Sheet.find(asset_params[:sheet_id]).assets.build(asset_params)
    @asset.save
  end

  def destroy
    @asset.destroy
    # TODO: delete S3 Bucket file?
    redirect_to :back
  end

  private
    def set_asset
      @asset = Asset.find(params[:id])
    end

    def asset_params
      params.permit(:sheet_id, :url, :filename, :filesize, :filetype)
    end

end