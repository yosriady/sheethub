class SheetsController < ApplicationController
  before_action :set_sheet, only: [:update]
  before_action :set_sheet_lazy, only: [:show, :edit, :report, :flag, :favorite, :favorites, :destroy, :download]
  before_action :set_deleted_sheet, only: [:restore]
  before_action :format_tag_fields, only: [:create, :update]
  before_action :validate_instruments, only: [:create, :update]
  before_action :set_all_tags, only: [:new, :create, :edit, :update]
  before_action :set_instruments
  before_action :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy, :restore]
  before_action :validate_flagged, only: [:show]
  before_action :hide_private_sheets, only: [:show, :report, :flag, :favorite, :download], if: :is_private_sheet
  before_action :authenticate_owner, :only => [:edit, :update, :destroy, :restore]

  TAG_FIELDS = [:composer_list, :genre_list, :source_list, :instruments_list]
  DEFAULT_FLAG_MESSAGE = 'No Message.'
  SUCCESS_FLAG_MESSAGE = "Succesfully reported! We'll come back to you in 72 hours."
  ERROR_UNSIGNED_FAVORITE_MESSAGE = 'You need to be signed in to favorite'
  SUCCESS_FAVORITE_MESSAGE = 'Sweet! Added to favorites.'
  SUCCESS_UNFAVORITE_MESSAGE = 'Removed from favorites.'
  SUCCESS_CREATE_SHEET_MESSAGE = "Woohoo! You've uploaded a new sheet."
  SUCCESS_UPDATE_SHEET_MESSAGE = "Fine piece of work! You've updated your sheet."
  ERROR_UPDATE_SHEET_MESSAGE = 'Oops! You cannot edit this Sheet because you are not the owner.'
  SUCCESS_DESTROY_SHEET_MESSAGE = 'Sheet was successfully destroyed.'
  SUCCESS_RESTORE_SHEET_MESSAGE = 'Sheet was successfully restored.'
  ERROR_SHEET_NOT_FOUND_MESSAGE = 'Oops! Sheet not found.'
  ERROR_CANNOT_RESTORE_UNDESTROYED_SHEET = 'You cannot restore an un-deleted Sheet.'
  ERROR_PDF_UNPURCHASED_MESSAGE = 'Buy now to get unlimited access to this file.'
  FLAGGED_MESSAGE = 'This Sheet has been flagged for a copyright violation.'
  ERROR_PRIVATE_SHEET_MESSAGE = 'This sheet is only visible to the owner.'
  SEARCH_PAGE_SIZE = 24

  # GET /sheets
  # GET /sheets.json
  def index
    @instruments = Sheet.values_for_instruments
    @sheets = Sheet.is_public.includes(:user).page(params[:page])
    @featured = Sheet.includes(:user).community_favorites.limit(3)
    @composers = Sheet.popular_composers
    @genres = Sheet.popular_genres
    @sources = Sheet.popular_sources
  end

  # GET /search
  def search
    track('View search results', query: params[:q])
    @sheets = Sheet.is_public.search params[:q], page: params[:page], per_page: SEARCH_PAGE_SIZE
  end

  def best_sellers
    track('View best sellers')
    @sheets = Sheet.get_best_sellers.page(params[:page])
  end

  def community_favorites
    track('View community favorites')
    @sheets = Sheet.get_community_favorites.page(params[:page])
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
    track('View sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
    @favorites = @sheet.votes_for.includes(:voter).limit(5)
  end

  def favorites
    @favorites = @sheet.votes_for.includes(:voter).page(params[:page]).per(50)
  end

  # Downloads Sheet PDF
  def download
    track('Download sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
    if @sheet.free? || @sheet.uploaded_by?(current_user)
      redirect_to @sheet.pdf_download_url
    elsif @sheet.purchased_by?(current_user)
      order = Order.find_by(user: current_user, sheet: @sheet)
      redirect_to order.pdf_download_url
    else
      flash[:error] = ERROR_PDF_UNPURCHASED_MESSAGE
      redirect_to sheet_url(@sheet)
    end
  end

  # GET /sheets/1/flag
  def report
  end

  # POST /sheets/1/flag
  def flag
    track('Flag sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
    message = params[:flag][:message].present? ? params[:flag][:message] : DEFAULT_FLAG_MESSAGE
    flag = Flag.create(user:current_user, sheet:@sheet, message:message, email:params[:flag][:email])
    SheetMailer.sheet_flagged_email(flag).deliver
    redirect_to sheet_url(@sheet), notice: SUCCESS_FLAG_MESSAGE
  end

  # Favorites/Unfavorites a Sheet
  def favorite
    track('Favorite sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
    unless current_user
      redirect_to new_user_session_url, error: ERROR_UNSIGNED_FAVORITE_MESSAGE
    end
    if @sheet && (!current_user.voted_for? @sheet)
      @sheet.favorited_by current_user
      redirect_to sheet_url(@sheet), notice: SUCCESS_FAVORITE_MESSAGE
    elsif @sheet && (current_user.voted_for? @sheet)
      @sheet.unfavorited_by current_user
      redirect_to sheet_url(@sheet), notice: SUCCESS_UNFAVORITE_MESSAGE
    else
      redirect_to root_url, error: ERROR_SHEET_NOT_FOUND_MESSAGE
    end
  end

  # GET /sheets/new
  def new
    track('View upload form')
    @sheet = Sheet.new
  end

  # GET /sheets/1/edit
  def edit
    @sheet.instruments_list = @sheet.instruments
  end

  # POST /sheets
  # POST /sheets.json
  def create
    create_params = build_tags(sheet_params)
    @sheet = Sheet.new(create_params)

    respond_to do |format|
      if @sheet.save
        track('Upload sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
        format.html { redirect_to @sheet, notice: SUCCESS_CREATE_SHEET_MESSAGE }
        format.json { render :show, status: :created, location: @sheet }
      else
        format.html { render :new }
        flash[:error] = @sheet.errors.full_messages.to_sentence
        format.json { render json: @sheet.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sheets/1
  # PATCH/PUT /sheets/1.json
  def update
    update_params = build_tags(sheet_params)
    @sheet.slug = nil #Regenerate friendly-id

    respond_to do |format|
      if @sheet.update(update_params)
        track('Update sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
        format.html { redirect_to @sheet, notice: SUCCESS_UPDATE_SHEET_MESSAGE }
        format.json { render :show, status: :ok, location: @sheet }
      else
        format.html { render :edit }
        flash[:error] = @sheet.errors.full_messages.to_sentence
        format.json { render json: @sheet.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @sheet.destroy
    track('Delete sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
    respond_to do |format|
      format.html { redirect_to user_trash_url, notice: SUCCESS_DESTROY_SHEET_MESSAGE }
      format.json { head :no_content }
    end
  end

  # Reverses soft-deletion
  def restore
    @sheet.restore
    track('Restore sheet', sheet_id: @sheet.id, sheet_title: @sheet.title)
    respond_to do |format|
      format.html { redirect_to sheet_url(@sheet), notice: SUCCESS_RESTORE_SHEET_MESSAGE }
      format.json { head :no_content }
    end
  end

  # GET /instruments
  def instruments
    track('View instruments')
    @instruments = Sheet.values_for_instruments
  end

  # GET /instrument/:slug
  def by_instrument
    track('View instrument', query: params[:slug])
    @sheets = Sheet.with_any_instruments(params[:slug]).page(params[:page])
  end

  # GET /genres
  def genres
    track('View genres')
    @genres = Sheet.is_public.tags_on(:genres)
  end

  # GET /genre/:slug
  def by_genre
    track('View genre', query: params[:slug])
    @sheets = Sheet.is_public.tagged_with(params[:slug], on: :genres).includes(:user).page(params[:page])
  end

  # GET /composers
  def composers
    track('View composers')
    @composers = Sheet.is_public.tags_on(:composers)
  end

  # GET /composer/:slug
  def by_composer
    track('View composer', query: params[:slug])
    @sheets = Sheet.is_public.tagged_with(params[:slug], on: :composers).includes(:user).page(params[:page])
  end

  # GET /sources
  def sources
    track('View sources')
    @sources = Sheet.is_public.tags_on(:sources)
  end

  # GET /source/:slug
  def by_source
    track('View source', query: params[:slug])
    @sheets = Sheet.is_public.tagged_with(params[:slug], on: :sources).includes(:user).page(params[:page])
  end

  def autocomplete
    track('Searched for', query: params[:query])
    render json: Sheet.is_public.search(params[:query], limit: 10).map{|s| {title: s.title, url: sheet_url(s)}}
  end

  private

  def build_tags(sheet_params)
    updated_params = sheet_params
    updated_params[:instruments] = params[:sheet][:instruments_list]
    updated_params[:composer_list] = params[:sheet][:composer_list]
    updated_params[:genre_list] = params[:sheet][:genre_list]
    updated_params[:source_list] = params[:sheet][:source_list]
    updated_params[:cached_joined_tags] = [params[:sheet][:instruments_list], params[:sheet][:composer_list], params[:sheet][:genre_list], params[:sheet][:source_list]].flatten.join ", "
    updated_params[:cached_genres] = params[:sheet][:genre_list].join ", "
    updated_params[:cached_composers] = params[:sheet][:composer_list].join ", "
    updated_params[:cached_sources] = params[:sheet][:source_list].join ", "
    return updated_params
  end

  def is_private_sheet
    @sheet && @sheet.privately_visible?
  end

  def hide_private_sheets
    return unless current_user != @sheet.user
    flash[:error] = ERROR_PRIVATE_SHEET_MESSAGE
    redirect_to discover_url
  end

  def authenticate_owner
    return if @sheet.user == current_user
    flash[:error] = ERROR_UPDATE_SHEET_MESSAGE
    redirect_to discover_url
  end

  def validate_flagged
    return unless @sheet.is_flagged
    flash[:error] = FLAGGED_MESSAGE
    redirect_to discover_url
  end

  def format_tag_fields
    # Clean up selectize tag values: genres, sources, composers, instruments
    TAG_FIELDS.each { |tag_field| format_tags(tag_field) }
  end

  def validate_instruments
    # Delete invalid instruments
    params[:sheet][:instruments_list].select! do |instrument|
      Sheet.values_for_instruments.include?(instrument)
    end
  end

  def set_sheet
    @sheet = Sheet.includes(:sources,
                            :composers,
                            :genres).friendly.find(params[:id])
  end

  def set_sheet_lazy
    @sheet = Sheet.friendly.find(params[:id])
  end

  def set_deleted_sheet
    @sheet = Sheet.only_deleted.friendly.find(params[:id])
  end

  def set_all_tags
    @composers = Sheet.is_public.tags_on(:composers)
    @genres = Sheet.is_public.tags_on(:genres)
    @sources = Sheet.is_public.tags_on(:sources)
  end

  def set_instruments
    gon.instruments ||= Sheet.values_for_instruments
  end

  def format_tags(tag_list)
    params[:sheet][tag_list].delete('')
    params[:sheet][tag_list] = params[:sheet][tag_list].map &:to_sym
  end

  def sheet_params
    params[:sheet].permit(:user_id, :title, :description, :instruments_list,
                          :composer_list, :genre_list, :source_list,
                          :cached_joined_tags, :pages, :difficulty, :pdf,
                          :assets_attributes, :visibility, :price, :license,
                          :enable_pdf_stamping, :pay_what_you_want)
  end
end
