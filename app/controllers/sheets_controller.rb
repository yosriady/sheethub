class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy]
  before_action :normalize_tag_fields, only: [:create, :update]
  before_action :validate_instruments, only: [:create, :update]
  before_action :set_tags
  before_action :set_instruments

  TAG_FIELDS = [:composer_list, :genre_list, :origin_list, :instruments_list]

  # GET /sheets
  # GET /sheets.json
  def index
    @sheets = Sheet.all
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
  end

  # GET /sheets/new
  def new
    @sheet = Sheet.new
  end

  # GET /sheets/1/edit
  def edit
  end

  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = Sheet.new(sheet_params)
    @sheet.instruments = params[:sheet][:instruments_list]
    @sheet.composer_list = params[:sheet][:composer_list]
    @sheet.genre_list = params[:sheet][:genre_list]
    @sheet.origin_list = params[:sheet][:origin_list]
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
      update_params[:origin_list] = params[:sheet][:origin_list]
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

  private
    def normalize_tag_fields
      TAG_FIELDS.each { |tag_field| normalize_tags(tag_field)} # Clean up selectize tag values
    end

    def validate_instruments
      params[:sheet][:instruments_list].select! {|instrument| Sheet.values_for_instruments.include?(instrument)} # Delete invalid instruments
    end

    def set_sheet
      @sheet = Sheet.find(params[:id])
    end

    def set_tags
      @composers ||= Sheet.tag_counts_on(:composers).collect{|tag| tag.name} # Just the tag names
      @genres ||= Sheet.tag_counts_on(:genres).collect{|tag| tag.name}
      @origins ||= Sheet.tag_counts_on(:origins).collect{|tag| tag.name}
    end

    def set_instruments
      gon.instruments ||= Sheet.values_for_instruments
    end

    def normalize_tags(tag_list)
      params[:sheet][tag_list].delete("")
      params[:sheet][tag_list] = params[:sheet][tag_list].map &:to_sym
    end

    def sheet_params
      params[:sheet].permit(:title, :description, :instruments_list, :composer_list, :genre_list, :origin_list,:pages, :difficulty, :pdf)
    end

end
