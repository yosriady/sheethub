class AssetsController < ApplicationController
  before_action :set_asset, only: [:destroy]
  before_action :unescape_url, only: [:create]

  def create
    @asset = Sheet.find(asset_params[:sheet_id]).assets.build(asset_params)
    @asset.save
  end

  def destroy
    @asset.destroy
    s3 = AWS::S3.new(:access_key_id => 'AKIAI32VLLBYAJJ2THYA',
                    :secret_access_key => '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',
                    :region => 'ap-southeast-1'
    )
    asset = s3.buckets['sheethub'].objects[@asset.s3_key]
    asset.delete
    redirect_to :back
  end

  private
    def set_asset
      @asset = Asset.find(params[:id])
    end

    def asset_params
      params.permit(:sheet_id, :url, :filename, :filesize, :filetype)
    end

    def unescape_url
      params[:url] = CGI.unescape(params[:url])
    end
end