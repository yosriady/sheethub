class AssetsController < ApplicationController
  before_action :set_asset, only: [:destroy]

  def create
    @asset = Sheet.find(asset_params[:sheet_id]).assets.build(asset_params)
    @asset.save
  end

  def destroy
    @asset.destroy
    s3 = AWS::S3.new
    bucket = s3.buckets['sheethub']
    bucket.objects['abc']
    binding.pry
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