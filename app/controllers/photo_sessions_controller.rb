class PhotoSessionsController < ApplicationController
  before_action :set_photo_session, only: [:show, :edit, :update, :destroy]

  # GET /photo_sessions
  # GET /photo_sessions.json
  def index

    emails = PhotoSession.tagged_with(["cevaris@gmail.com,jim.kobol@gmail.com"], :any => true)
    if params[:email_list]
      emails = PhotoSession.tagged_with(params[:email_list].split, :any => true)
    else
      emails = []
    end
    
    if params[:phone_list]
      phones = PhotoSession.tagged_with(params[:phone_list].split, :any => true)
    else
      phones = []
    end

    @photo_sessions = emails | phones
  end

  # GET /photo_sessions/1
  # GET /photo_sessions/1.json
  def show
  end

  # GET /photo_sessions/new
  def new
    @photo_session = PhotoSession.new
    3.times { @photo_session.photos.build }
    # @photo_session.email_list = 'cevaris@gmail.com,chek@yahoo.com'
  end

  # GET /photo_sessions/1/edit
  def edit
  end

  # # POST /photo_sessions
  # # POST /photo_sessions.json
  # def create
  #   @photo_session = PhotoSession.new(photo_session_params)

  #   respond_to do |format|
  #     if @photo_session.save
  #       format.html { redirect_to @photo_session, notice: 'Photo session was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @photo_session }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @photo_session.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end


  # POST /activities
  # POST /activities.json
  def create
    Rails.logger.info "Before: #{params}"

    # if params.has_key?(:photo_session) and params[:photo_session].has_key?(:phones)
    #   params[:photo_session][:emails] = params[:photo_session][:emails].split
    # end
    # if params[:photo_session].has_key?(:emails) and params[:photo_session][:emails].empty?
    #   params[:photo_session][:emails] = ""
    # end
    # if params[:photo_session].has_key?(:phones) and params[:photo_session][:phones].empty?
    #   params[:photo_session][:phones] = ""
    #   # params[:photo_session][:phones] = params[:photo_session][:phones].split
    # end

    Rails.logger.info "After: #{params}"

    @photo_session = PhotoSession.new(photo_session_params)
    @photo_session.photographer = current_user
    # @photo_session.phone_list = params[:photo_session][:phones]
    # @photo_session.email_list = params[:photo_session][:emails]

    # if params.has_key?(:photo_session) and params[:photo_session].has_key?(:phones)
    #   @photo_session.phone_list = params[:photo_session][:emails]
    # end
    # if params.has_key?(:photo_session) and params[:photo_session].has_key?(:emails)
    #   @photo_session.email_list = params[:photo_session][:emails]
    # end

    respond_to do |format|
      if @photo_session.save
        format.html { redirect_to @photo_session, notice: 'Photo Session was successfully created.' }
        format.json { render json: @photo_session, status: :created, location: @photo_session }
      else
        # Delete images post invalidation
        @photo_session.photos.map(&:destroy)
        @photo_session.photos = []
        3.times { @photo_session.photos.build }

        format.html { render action: "new" }
        format.json { render json: @photo_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photo_sessions/1
  # PATCH/PUT /photo_sessions/1.json
  def update
    respond_to do |format|
      if @photo_session.update(photo_session_params)
        format.html { redirect_to @photo_session, notice: 'Photo session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @photo_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_sessions/1
  # DELETE /photo_sessions/1.json
  def destroy
    @photo_session.destroy
    respond_to do |format|
      format.html { redirect_to photo_sessions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo_session
      @photo_session = PhotoSession.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_session_params
      #params.require(:photo_session).permit(:name, :photo_user_id, :event_id, :phones, :emails, :photos_attributes)
      params.require(:photo_session).permit!
    end
end