class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy]
  before_action :normalize_tag_fields, only: [:create, :update]
  before_action :validate_instruments, only: [:create, :update]
  before_action :set_tags
  before_action :set_instruments

  TAG_FIELDS = [:composer_list, :genre_list, :source_list, :instruments_list]

  # GET /sheets
  # GET /sheets.json
  def index
    @sheets = Sheet.all
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
    gon.pdf_url = @sheet.pdf.url
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
        format.html { redirect_to @sheet, notice: 'Sheet was successfully created.' }
        format.json { render :show, status: :created, location: @sheet }
      else
        format.html { render :new }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sheets/1
  # PATCH/PUT /sheets/1.json
  def update
    respond_to do |format|
      update_params = sheet_params
      update_params[:instruments] = params[:sheet][:instruments_list]
      update_params[:composer_list] = params[:sheet][:composer_list]
      update_params[:genre_list] = params[:sheet][:genre_list]
      update_params[:source_list] = params[:sheet][:source_list]
      if @sheet.update(update_params)
        format.html { redirect_to @sheet, notice: 'Sheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @sheet }
      else
        format.html { render :edit }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @sheet.destroy
    respond_to do |format|
      format.html { redirect_to sheets_url, notice: 'Sheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /genres
  def genres
  end

  # GET /genre/:slug
  def by_genre
    @sheets = Sheet.tagged_with(params[:slug], :on => :genres)
  end

  # GET /composers
  def composers
  end

  # GET /composer/:slug
  def by_composer
    @sheets = Sheet.tagged_with(params[:slug], :on => :composers)
  end

  # GET /sources
  def sources
  end

  # GET /source/:slug
  def by_source
    @sheets = Sheet.tagged_with(params[:slug], :on => :sources)
  end

  private
    def normalize_tag_fields
      TAG_FIELDS.each { |tag_field| normalize_tags(tag_field)} # Clean up selectize tag values: genres, sources, composers, instruments
    end

    def validate_instruments
      params[:sheet][:instruments_list].select! {|instrument| Sheet.values_for_instruments.include?(instrument)} # Delete invalid instruments
    end

    def set_sheet
      @sheet = Sheet.find(params[:id])
    end

    def set_tags
      @composers ||= Sheet.tags_on(:composers)
      @genres ||= Sheet.tags_on(:genres)
      @sources ||= Sheet.tags_on(:sources)
    end

    def set_instruments
      gon.instruments ||= Sheet.values_for_instruments
    end

    def normalize_tags(tag_list)
      params[:sheet][tag_list].delete("")
      params[:sheet][tag_list] = params[:sheet][tag_list].map &:to_sym
    end

    def sheet_params
      params[:sheet].permit(:title, :description, :instruments_list, :composer_list, :genre_list, :source_list,:pages, :difficulty, :pdf, :assets_attributes)
    end

end
