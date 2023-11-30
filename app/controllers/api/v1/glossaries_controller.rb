class Api::V1::GlossariesController < API::APIController
  skip_before_filter :verify_authenticity_token, :only => :update

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

  def update
    glossary = Glossary.find(params[:id])
    authorize! :manage, glossary
    if params[:name]
      glossary.name = params[:name]
    end
    if params[:json]
      # handle either a string or an object, saving as a string to the model
      if params[:json].kind_of?(String)
        glossary.json = params[:json]
      else
        glossary.json = params[:json].to_json
      end
    end
    if params.has_key?(:project)
      if params[:project].nil?
        glossary.project_id = nil
      else
        glossary.project_id = params[:project]["id"]
      end
    end
    begin
      glossary.save!
    rescue => e
      error(e.message)
    else
      render :json => {id: glossary.id, name: glossary.name, project: Project.id_and_title(glossary.project), json: glossary.export_json_only}
    end
  end
end
