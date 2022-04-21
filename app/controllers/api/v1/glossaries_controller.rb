class Api::V1::GlossariesController < API::APIController
  # GET /api/v1/glossaries/1.json
  def show
    glossary = Glossary.find(params[:id])
    if params[:json_only]
      render json: glossary.export_json_only.to_json
    else
      render json: glossary.export(current_user).to_json
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
    begin
      glossary.save!
    rescue => e
      error(e.message)
    else
      render :json => {id: glossary.id, name: glossary.name, json: glossary.export_json_only}
    end
  end
end
