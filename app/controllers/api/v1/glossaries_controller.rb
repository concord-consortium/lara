class Api::V1::GlossariesController < API::APIController
  # GET /api/v1/glossaries/1.json
  def show
    glossary = Glossary.find(params[:id])
    if params[:json_only]
      render json: glossary.export_json_only.to_json
    else
      render json: glossary.export.to_json
    end
  end
end
