class ProjectsController < ApplicationController
  load_and_authorize_resource

  # GET /projects
  # GET /projects.json
  def index
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to edit_project_url(@project), notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_params
    params.fetch(:project)
          .permit(
            :footer, :logo_lara, :logo_ap, :title, :url, :about, :project_key, :copyright,
            :copyright_image_url, :collaborators, :funders_image_url, :collaborators_image_url,
            :contact_email, :admin_ids
          )
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update_attributes(update_params)
        format.html { redirect_to edit_polymorphic_url(@project), notice: "Project was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  def about
    respond_to do |format|
      format.js{ render :json => { :html => render_to_string('about')}, :content_type => 'text/json' }
      format.html {}
    end
  end
  
  def help
    respond_to do |format|
      format.js{ render :json => { :html => render_to_string('help')}, :content_type => 'text/json' }
      format.html {}
    end
  end
  
  def contact_us
    respond_to do |format|
      format.js{ render :json => { :html => render_to_string('shared/_contact_us')}, :content_type => 'text/json' }
      format.html {}
    end
  end
  
end
