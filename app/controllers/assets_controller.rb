class AssetsController < ApplicationController
  ERROR_SHEET_UNPURCHASED_MESSAGE = 'You do not have access to this file.'

  before_action :set_asset, only: [:destroy, :download]
  before_action :unescape_url, only: [:create]

  def create
    sheet = Sheet.find(asset_params[:sheet_id])
    @asset = sheet.assets.build(asset_params)
    if @asset.valid?
      @asset.save
    else
      # TOOD: Fix this
      # flash[:error] = @asset.errors.full_messages.to_sentence
      # redirect_to edit_sheet_path(sheet)
    end
  end

  def destroy
    @asset.destroy
    s3 = AWS::S3.new(:access_key_id => 'AKIAI32VLLBYAJJ2THYA',
                    :secret_access_key => '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',
                    :region => 'ap-southeast-1'
    )
    asset = s3.buckets['sheethub'].objects[@asset.s3_key]
    asset.delete
    flash[:notice] = "Yay! File succesfully deleted."
    redirect_to :back
  end

  def download
    sheet = @asset.sheet
    if sheet.is_free? || sheet.purchased_by?(current_user) || sheet.uploaded_by?(current_user)
      redirect_to @asset.download_url
    else
      # TODO: Message not displayed
      flash[:error] = ERROR_SHEET_UNPURCHASED_MESSAGE
      redirect_to sheet_path(sheet)
    end
  end

  def destroy
    sheet = @asset.sheet
    if sheet.user == current_user
      @asset.destroy
      # TODO: flash messages not displayed, use render "sheets/edit" ?
      redirect_to :back, notice: "File removed succesfully."
    else
      redirect_to :back, error: "You do not have permission to remove this file."
    end
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