class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authenticate_owner, only: [:edit, :update, :destroy]

  ERROR_UPDATE_NOTE_MESSAGE = 'Oops! You cannot edit this Note because you are not the owner.'

  # GET /notes
  def index
    @notes = Note.all
  end

  # GET /notes/1
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes
  def create
    @note = Note.new(note_params)
    if @note.save
      redirect_to @note, notice: 'Note was successfully created.'
    else
      flash[:error] = @note.errors.full_messages.to_sentence
      render :new
    end
  end

  # PATCH/PUT /notes/1
  def update
    if @note.update(note_params)
      redirect_to @note, notice: 'Note was successfully updated.'
    else
      flash[:error] = @note.errors.full_messages.to_sentence
      render :edit
    end
  end

  # DELETE /notes/1
  def destroy
    @note.destroy
    redirect_to notes_url, notice: 'Note was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.friendly.find(params[:id])
    end

    def authenticate_owner
      return if @note.user == current_user
      flash[:error] = ERROR_UPDATE_NOTE_MESSAGE
      redirect_to discover_url
    end

    # Only allow a trusted parameter "white list" through.
    def note_params
      params.require(:note).permit(:user_id, :title, :description, :body, :visibility, :body_type)
    end
end
