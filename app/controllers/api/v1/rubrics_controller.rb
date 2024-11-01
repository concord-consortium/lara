class Api::V1::RubricsController < API::APIController
  skip_before_action :verify_authenticity_token, :only => :update

  # GET /api/v1/rubrics/1.json
  def show
    rubric = Rubric.find(params[:id])
    data = rubric.export(current_user)
    # don't send the full project object, just the data needed for the select
    data[:project] = Project.id_and_title(rubric.project)
    render json: data.to_json
  end

  def update
    rubric = Rubric.find(params[:id])
    authorize! :manage, rubric
    if params[:name]
      rubric.name = params[:name]
    end
    if params[:referenceUrl]
      rubric.doc_url = params[:referenceUrl]
    end
    if params.has_key?(:project)
      if params[:project].nil?
        rubric.project_id = nil
      else
        rubric.project_id = params[:project]["id"]
      end
    end
    begin
      rubric.save!
    rescue => e
      error(e.message)
    else
      render :json => {id: rubric.id, name: rubric.name, doc_url: rubric.doc_url, project: Project.id_and_title(rubric.project)}
    end
  end
end
