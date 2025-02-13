class Api::V1::GlossariesController < Api::ApiController
  skip_before_action :verify_authenticity_token, only: :update

  # GET /api/v1/glossaries/1.json
  def show
    glossary = Glossary.find(params[:id])
    if params[:json_only]
      render json: glossary.export_json_only.to_json
    else
      data = glossary.export(current_user)
      # don't send the full project object to the plugin
      data[:project] = Project.id_and_title(glossary.project)
      render json: data.to_json
    end
  end

  def glossary_params
    params.require(:glossary).permit(:name, :json, :user_id, :legacy_glossary_resource_id, :project_id, :project)
  end

  def update
    glossary = Glossary.find(params[:id])
    authorize! :manage, glossary

    if params[:glossary].has_key?(:name)
      glossary.name = params[:glossary][:name]
    end

    if params[:glossary][:json].present?
      if params[:glossary][:json].kind_of?(String)
        glossary.json = params[:glossary][:json]
      else
        glossary.json = params[:glossary][:json].to_json
      end
    end

    if params[:glossary].has_key?(:project)
      if params[:glossary][:project].nil?
        glossary.project_id = nil
      else
        glossary.project_id = params[:glossary][:project]["id"]
      end
    end

    begin
      glossary.save!
    rescue => e
      error(e.message)
    else
      render json: {id: glossary.id, name: glossary.name, project: Project.id_and_title(glossary.project), json: glossary.export_json_only}
    end
  end
end
