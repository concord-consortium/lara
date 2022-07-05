class Api::V1::ThemesController < API::APIController

  # GET /api/v1/themes
  def index
    @themes = Theme.all
    render json: {themes: @themes}
  end

end