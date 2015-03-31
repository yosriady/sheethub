class API::V1::SheetsController < API::APIController
  respond_to :json
  # before_action :authenticate

  def index
    @sheets = Sheet.is_public.includes(:assets).page(params[:page])
    respond_with @sheets
  end

  def show
    @sheet = Sheet.friendly.find(params[:id])
    respond_with @sheet
  end
end
