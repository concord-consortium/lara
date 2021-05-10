class LibraryInteractivesController < ApplicationController
  before_filter :can_use_index, :only => :index
  before_filter :can_manage, :except => :index

  # GET /library_interactives
  # GET /library_interactives.json
  def index
    @library_interactives = LibraryInteractive.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @library_interactives }
    end
  end

  # GET /library_interactives/new
  # GET /library_interactives/new.json
  def new
    @library_interactive = LibraryInteractive.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @library_interactive }
    end
  end

  # GET /library_interactives/1/edit
  def edit
    @library_interactive = LibraryInteractive.find(params[:id])
  end

  # POST /library_interactives
  # POST /library_interactives.json
  def create
    @library_interactive = LibraryInteractive.new(params[:library_interactive])

    respond_to do |format|
      if @library_interactive.save
        format.html { redirect_to library_interactives_url, notice: 'Library interactive was successfully created.' }
        format.json { render json: @library_interactive, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @library_interactive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /library_interactives/1
  # PUT /library_interactives/1.json
  def update
    @library_interactive = LibraryInteractive.find(params[:id])

    respond_to do |format|
      if @library_interactive.update_attributes(params[:library_interactive])
        format.html { redirect_to library_interactives_url, notice: 'Library interactive was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @library_interactive.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /library_interactives/1/migrate
  def migrate
    @library_interactive = LibraryInteractive.find(params[:id]) 
  end

  # DELETE /library_interactives/1
  # DELETE /library_interactives/1.json
  def destroy
    @library_interactive = LibraryInteractive.find(params[:id])
    @library_interactive.destroy

    respond_to do |format|
      format.html { redirect_to library_interactives_url }
      format.json { head :no_content }
    end
  end

  private

  def can_use_index
    # allow json reads of index by authors
    if request.format.json?
      raise CanCan::AccessDenied unless current_user.author? or current_user.admin?
    else
      authorize! :manage, LibraryInteractive
    end
  end

  def can_manage
    authorize! :manage, LibraryInteractive
  end

end
