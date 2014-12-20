# Asset (Sheet additionalfile) management
class AssetsController < ApplicationController
  ERROR_SHEET_UNPURCHASED_MESSAGE = 'You do not have access to this file.'
  SUCCESS_ASSET_DESTROY_MESSAGE = 'File removed succesfully.'
  INVALID_PERMISSION_MESSAGE = 'You do not have permission to remove this file.'

  before_action :set_asset, only: [:destroy, :download]
  before_action :unescape_url, only: [:create]

  def create
    sheet = Sheet.find(asset_params[:sheet_id])
    @asset = sheet.assets.build(asset_params)
    if @asset.valid?
      @asset.save
      track('Upload sheet asset', { asset_name: @asset.filename, sheet_id: sheet.id, sheet_title: sheet.title })
    else
      s3_key = Asset.parse_s3_key(params[:url])
      delete_s3_object(s3_key)
      # TOOD: This error message is not displayed
      flash[:error] = @asset.errors.full_messages.to_sentence
      redirect_to edit_sheet_path(sheet)
    end
  end

  def destroy
    sheet = @asset.sheet
    if sheet.user == current_user
      @asset.really_destroy!
      delete_s3_object(@asset.s3_key)
      track('Delete sheet asset', { asset_name: @asset.filename, sheet_id: sheet.id, sheet_title: sheet.title })
      # TODO: flash messages not displayed, use render "sheets/edit" ?
      flash[:notice] = SUCCESS_ASSET_DESTROY_MESSAGE
    else
      flash[:error] = INVALID_PERMISSION_MESSAGE
    end
    redirect_to edit_sheet_path(sheet)
  end

  def download
    sheet = @asset.sheet
    track('Download sheet asset', { asset_name: @asset.filename, sheet_id: sheet.id, sheet_title: sheet.title })
    if sheet.free? || sheet.purchased_by?(current_user) || sheet.uploaded_by?(current_user)
      redirect_to @asset.download_url
    else
      # FIX: Message not displayed
      flash[:error] = ERROR_SHEET_UNPURCHASED_MESSAGE
      redirect_to sheet_path(sheet)
    end
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def delete_s3_object(key)
    s3 = AWS::S3.new
    asset = s3.buckets[S3DirectUpload.config.bucket].objects[key]
    asset.delete
  end

  def asset_params
    params.permit(:sheet_id, :url, :filename, :filesize, :filetype)
  end

  def unescape_url
    params[:url] = CGI.unescape(params[:url])
  end
end
