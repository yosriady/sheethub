class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy]
  before_action :normalize_instruments, only: [:create, :update]
  before_action :normalize_tags, only: [:create, :update]
  before_action :set_tags
  before_action :set_instruments

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
    @sheet.instruments = params[:sheet][:instruments]
    @sheet.tag_list = params[:sheet][:tag_list]
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
      update_params[:instruments] = params[:sheet][:instruments]
      update_params[:tag_list] = params[:sheet][:tag_list]
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
    def set_sheet
      @sheet = Sheet.find(params[:id])
    end

    def set_tags
      @tags ||= Sheet.tag_counts_on(:tags).collect{|tag| tag.name} # Just the tag names
    end

    def set_instruments
      gon.instruments ||= Sheet.values_for_instruments
    end

    def sheet_params
      binding.pry
      params[:sheet].permit(:title, :description, :instruments, :tag_list, :pages)
    end

    def normalize_tags
      params[:sheet][:tag_list].delete("") # Delete space from selectize.js
      params[:sheet][:tag_list] = params[:sheet][:tag_list].map &:to_sym
    end

    def normalize_instruments
      params[:sheet][:instruments].delete("") # Delete space from selectize.js
      params[:sheet][:instruments] = params[:sheet][:instruments].map &:to_sym
      params[:sheet][:instruments].select! {|instrument| Sheet.values_for_instruments.include?(instrument)} # Delete invalid instruments
    end

end
