class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy, :flag, :like, :download_pdf]
  before_action :normalize_tag_fields, only: [:create, :update]
  before_action :validate_instruments, only: [:create, :update]
  before_action :set_all_tags, only: [:new, :create, :edit, :update]
  before_action :set_instruments
  before_action :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy]
  before_action :authenticate_owner, :only => [:edit, :update, :destroy]

  TAG_FIELDS = [:composer_list, :genre_list, :source_list, :instruments_list]
  DEFAULT_FLAG_MESSAGE = "No Message."
  SUCCESS_FLAG_MESSAGE = "Succesfully reported! We'll come back to you in 72 hours."
  ERROR_UNSIGNED_LIKE_MESSAGE = 'You need to be signed in to like'
  SUCCESS_LIKE_MESSAGE = 'Liked!'
  SUCCESS_UNLIKE_MESSAGE = 'Unliked!'
  SUCCESS_CREATE_SHEET_MESSAGE = 'Sheet was successfully created.'
  SUCCESS_UPDATE_SHEET_MESSAGE = 'Sheet was successfully updated.'
  ERROR_UPDATE_SHEET_MESSAGE = 'You cannot edit this Sheet because you are not the owner.'
  SUCCESS_DESTROY_SHEET_MESSAGE = 'Sheet was successfully destroyed.'

  # GET /sheets
  # GET /sheets.json
  def index
    @instruments = Sheet.values_for_instruments
    @sheets = Sheet.is_public.includes(:user).sorted(params[:sort_order]).page(params[:page])

    # TODO: These should be cached, only show the most popular ones every 24 hours?
    @composers ||= Sheet.tags_on(:composers).limit(10)
    @genres ||= Sheet.tags_on(:genres).limit(10)
    @sources ||= Sheet.tags_on(:sources).limit(10)
  end

  # GET /search
  def search
    @sheets = Sheet.is_public.search params[:q], page: params[:page]
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
  end

  def download_pdf
    redirect_to @sheet.pdf_download_url
  end

  # POST /sheets/1/flag
  def flag
    message = params[:flag][:message].present? ? params[:flag][:message] : DEFAULT_FLAG_MESSAGE
    Flag.create(user_id:current_user, sheet_id:@sheet.id, message:message, email:params[:flag][:email])
    redirect_to sheet_path(@sheet), notice: SUCCESS_FLAG_MESSAGE
  end

  def like
    unless current_user
      redirect_to new_user_session_path, error: ERROR_UNSIGNED_LIKE_MESSAGE
    end
    if @sheet && (!current_user.voted_for? @sheet)
      @sheet.liked_by current_user
      redirect_to sheet_path(@sheet), notice: SUCCESS_LIKE_MESSAGE
    elsif @sheet && (current_user.voted_for? @sheet)
      @sheet.unliked_by current_user
      redirect_to sheet_path(@sheet), notice: SUCCESS_UNLIKE_MESSAGE
    else
      redirect_to root_path, error: 'Sheet not found'
    end
  end

  # GET /sheets/new
  def new
    @sheet = Sheet.new
  end

  # GET /sheets/1/edit
  def edit
    @sheet.instruments_list = @sheet.instruments
  end

  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = Sheet.new(sheet_params)
    @sheet.instruments = params[:sheet][:instruments_list]
    @sheet.composer_list = params[:sheet][:composer_list]
    @sheet.genre_list = params[:sheet][:genre_list]
    @sheet.source_list = params[:sheet][:source_list]

    respond_to do |format|
      if @sheet.save
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
    respond_to do |format|
      update_params = sheet_params
      @sheet.slug = nil #Regenerate friendly-id
      update_params[:instruments] = params[:sheet][:instruments_list]
      update_params[:composer_list] = params[:sheet][:composer_list]
      update_params[:genre_list] = params[:sheet][:genre_list]
      update_params[:source_list] = params[:sheet][:source_list]
      if @sheet.update(update_params)
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
    respond_to do |format|
      format.html { redirect_to sheets_url, notice: SUCCESS_DESTROY_SHEET_MESSAGE }
      format.json { head :no_content }
    end
  end

  # GET /instruments
  def instruments
      @instruments = Sheet.values_for_instruments
  end

  # GET /instrument/:slug
  def by_instrument
      @sheets = Sheet.with_exact_instruments(params[:slug])
  end

  # GET /genres
  def genres
    @genres = Sheet.is_public.tags_on(:genres)
  end

  # GET /genre/:slug
  def by_genre
    @sheets = Sheet.is_public.tagged_with(params[:slug], :on => :genres)
  end

  # GET /composers
  def composers
    @composers = Sheet.is_public.tags_on(:composers)
  end

  # GET /composer/:slug
  def by_composer
    @sheets = Sheet.is_public.tagged_with(params[:slug], :on => :composers)
  end

  # GET /sources
  def sources
    @sources = Sheet.is_public.tags_on(:sources)
  end

  # GET /source/:slug
  def by_source
    @sheets = Sheet.is_public.tagged_with(params[:slug], :on => :sources)
  end

  def autocomplete
    render json: Sheet.is_public.search(params[:query], limit: 10).map{|s| {title: s.title, url: sheet_path(s)}}
  end

  private
    def authenticate_owner
      unless @sheet.user == current_user
        flash[:error] = ERROR_UPDATE_SHEET_MESSAGE
        redirect_to root_path
      end
    end

    def normalize_tag_fields
      TAG_FIELDS.each { |tag_field| normalize_tags(tag_field)} # Clean up selectize tag values: genres, sources, composers, instruments
    end

    def validate_instruments
      params[:sheet][:instruments_list].select! {|instrument| Sheet.values_for_instruments.include?(instrument)} # Delete invalid instruments
    end

    def set_sheet
      @sheet = Sheet.friendly.find(params[:id])
    end

    def set_all_tags
      @composers = Sheet.is_public.tags_on(:composers)
      @genres = Sheet.is_public.tags_on(:genres)
      @sources = Sheet.is_public.tags_on(:sources)
    end

    def set_instruments
      gon.instruments ||= Sheet.values_for_instruments
    end

    def normalize_tags(tag_list)
      params[:sheet][tag_list].delete("")
      params[:sheet][tag_list] = params[:sheet][tag_list].map &:to_sym
    end

    def sheet_params
      params[:sheet].permit(:user_id, :title, :description, :instruments_list, :composer_list, :genre_list, :source_list,:pages, :difficulty, :pdf, :assets_attributes, :is_public)
    end

end
