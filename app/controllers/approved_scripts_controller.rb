class ApprovedScriptsController < ApplicationController
  load_and_authorize_resource
  # GET /approved_scripts
  # GET /approved_scripts.json

  def approved_script_params
    params.require(:approved_script).permit(:name, :url, :label, :description, :version, :json_url, :authoring_metadata)
  end

  def index
    @approved_scripts = ApprovedScript.all

    respond_to do |format|
      format.html # index.html.html.haml
      format.json { render json: @approved_scripts }
    end
  end

  # GET /approved_scripts/1
  # GET /approved_scripts/1.json
  def show
    @approved_script = ApprovedScript.find(params[:id])

    respond_to do |format|
      format.html # show.html.html.haml
      format.json { render json: @approved_script }
    end
  end

  # GET /approved_scripts/new
  # GET /approved_scripts/new.json
  def new
    @approved_script = ApprovedScript.new

    respond_to do |format|
      format.html # new.html.html.haml
      format.json { render json: @approved_script }
    end
  end

  # GET /approved_scripts/1/edit
  def edit
    @approved_script = ApprovedScript.find(params[:id])
  end

  # POST /approved_scripts
  # POST /approved_scripts.json
  def create
    @approved_script = ApprovedScript.new(approved_script_params)

    respond_to do |format|
      if @approved_script.save
        format.html { redirect_to approved_scripts_url, notice: 'Approved script was successfully created.' }
        format.json { render json: @approved_script, status: :created, location: @approved_script }
      else
        format.html { render action: "new" }
        format.json { render json: @approved_script.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_params
    params.require(:approved_script).permit(:name, :url, :label, :description, :version, :json_url, :authoring_metadata)
  end

  # PUT /approved_scripts/1
  # PUT /approved_scripts/1.json
  def update
    @approved_script = ApprovedScript.find(params[:id])

    respond_to do |format|
      if @approved_script.update(update_params)
        format.html { redirect_to approved_scripts_url, notice: 'Approved script was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @approved_script.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approved_scripts/1
  # DELETE /approved_scripts/1.json
  def destroy
    @approved_script = ApprovedScript.find(params[:id])
    @approved_script.destroy

    respond_to do |format|
      format.html { redirect_to approved_scripts_url }
      format.json { head :no_content }
    end
  end
end
