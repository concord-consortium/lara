class Api::V1::ProjectsController < API::APIController

  skip_before_filter :verify_authenticity_token

  # GET /api/v1/projects
  def index
    @projects = Project.all
    authorize! :manage, @projects
    render json: {projects: @projects}
  end

  # GET /api/v1/projects/1.json
  def show
    begin
      @project = Project.find(params[:id])
      authorize! :manage, @project
      render json: {project: @project}, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Project not found"}, status: 404
    end
  end

  # POST /api/v1/projects
  def create
    @project = Project.new(params[:project])
    authorize! :create, @project
    if @project.save
      render json: {success: true, project: @project}, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # POST /api/v1/projects/1.json
  def update
    @updated_project_hash = params[:project]
    @project = Project.find(@updated_project_hash[:id]);
    authorize! :update, @project
    if @project.update_attributes(@updated_project_hash)
      render json: {success: true, project: @project}, status: :ok
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/delete_project/1.json
  def destroy
    @project = Project.find(params[:id])
    authorize! :delete, @project
    if @project.destroy
      render json: {success: true}, status: 200
    else
      render json: @project.errors, status: :unprocessable_entity
    end  
  end

end