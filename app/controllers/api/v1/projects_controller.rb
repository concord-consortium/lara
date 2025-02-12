class Api::V1::ProjectsController < API::APIController

  skip_before_action :verify_authenticity_token

  # GET /api/v1/projects
  def index
    @projects = Project.visible_to_user(current_user)
    authorize! :manage, Project
    render json: {projects: @projects}
  end

  # GET /api/v1/projects/1.json
  def show
    begin
      @project = Project.includes(:admins).find(params[:id])
      authorize! :manage, @project
      render json: {project: @project, admins: admin_json(@project)}, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Project not found"}, status: 404
    end
  end

  def project_params
    params.require(:project).permit(
      :footer, :logo_lara, :logo_ap, :title, :url, :about, :project_key, :copyright,
      :copyright_image_url, :collaborators, :funders_image_url, :collaborators_image_url,
      :contact_email, :admin_ids
    )
  end

  # POST /api/v1/projects
  def create
    @project = Project.new(project_params)
    authorize! :create, @project
    if @project.save
      render json: {success: true, project: @project}, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # POST /api/v1/projects/1.json
  def update
    @updated_project_hash = project_params
    @project = Project.find(params[:id]);
    authorize! :update, @project

    # extract the ids from the passed admin objects and remove any extra admins in the update that
    # are not in the original, to ensure we can only remove and not add project admins
    @updated_project_hash[:admin_ids] = (params[:project][:admins] || [])
      .select { |admin| @project.admin_ids.include?(admin[:id].to_i) }
      .map { |admin| admin[:id] }

    if @project.update(@updated_project_hash)
      render json: {success: true, project: @project, admins: admin_json(@project)}, status: :ok
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

  private

  def admin_json(project)
    project.admins.map { |a| {id: a.id, email: a.email} }
  end

end
