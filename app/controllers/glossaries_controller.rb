class GlossariesController < ApplicationController
  before_action :set_glossary, except: [:index, :new, :create]

  def index
    @filter  = CollectionFilter.new(current_user, Glossary, params[:filter] || {})
    @glossaries = @filter.collection.includes(:user).paginate(page: params['page'], per_page: 20)
  end

  def new
    authorize! :create, Glossary
    @glossary = Glossary.new()
  end

  def glossary_params
    params.fetch(:glossary, {}).permit(:name, :json, :user_id,
    :legacy_glossary_resource_id, :project_id, :project)
  end

  def create
    authorize! :create, Glossary
    @glossary = Glossary.new(glossary_params)
    @glossary.user = current_user

    if @glossary.save
      redirect_to edit_glossary_url(@glossary), notice: 'Glossary was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @can_edit = @glossary.can_edit(current_user)
    # any user can see the edit form as it has a special readonly view
    @approved_glossary_script = Glossary.get_glossary_approved_script()
    @project = Project.id_and_title(@glossary.project)
    @projects = Project.visible_to_user(current_user).map {|p| Project.id_and_title(p)}
  end

  def update
    authorize! :update, @glossary
    respond_to do |format|
      if @glossary.update_attributes(glossary_params)
        format.html { redirect_to edit_polymorphic_url(@glossary), notice: "Glossary was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @glossary.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @glossary
    if @glossary.can_delete()
      @glossary.destroy
    end
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
    send_data glossary_json, type: :json, disposition: "attachment", filename: "#{@glossary.name}_version_2.json"
  end

  private

  def set_glossary
    @glossary = Glossary.find(params[:id])
  end

end
