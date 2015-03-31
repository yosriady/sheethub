class API::V1::SheetsController < API::APIController
  respond_to :json
  # before_action :authenticate

  # GET /v1/sheets
  def index
    @sheets = Sheet.is_public.includes(:assets).page(params[:page])
    respond_with @sheets
  end

  # GET /v1/sheets/:id
  def show
    @sheet = Sheet.friendly.find(params[:id])
    respond_with @sheet
  end

  # POST /v1/sheets/search
  def search
    @sheets = Sheet.filter(params)
    render json: @sheets, each_serializer: SheetSerializer
  end
end
