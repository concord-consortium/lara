class GlossariesController < ApplicationController
  load_and_authorize_resource

  def index
    @filter  = CollectionFilter.new(current_user, Glossary, params[:filter] || {})
    @glossaries = @filter.collection.includes(:user).paginate(:page => params['page'], :per_page => 20)
  end

  def new
    @glossary = Glossary.new()
  end

  def create
    @glossary = Glossary.new(params[:glossary])
    @glossary.user = current_user

    if @glossary.save
      redirect_to edit_glossary_url(@glossary), notice: 'Glossary was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @approved_glossary_script = Glossary.get_glossary_approved_script()
  end

  def update
    simple_update(@glossary)
  end

  def destroy
    @glossary.destroy
    redirect_to glossaries_url
  end

  def duplicate
    authorize! :duplicate, @glossary
    @new_glossary = @glossary.duplicate(current_user)

    if @new_glossary.save
      redirect_to edit_glossary_path(@new_glossary)
    else
      flash[:warning] = "Copy failed"
      redirect_to glossaries_path
    end
  end

  def export
    authorize! :export, @glossary
    glossary_json = @glossary.to_export_hash.to_json
    send_data glossary_json, type: :json, disposition: "attachment", filename: "#{@glossary.name}_version_1.json"
  end

end
