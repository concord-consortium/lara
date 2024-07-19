class RubricsController < ApplicationController
  before_filter :set_rubric, :except => [:index, :new, :create]

  def index
    @filter  = CollectionFilter.new(current_user, Rubric, params[:filter] || {})
    @rubrics = @filter.collection.includes(:user).paginate(:page => params['page'], :per_page => 20)
  end

  def new
    authorize! :create, Rubric
    @rubric = Rubric.new()
  end

  def create
    authorize! :create, Rubric
    @rubric = Rubric.new(params[:rubric])
    @rubric.user = current_user

    if @rubric.save
      redirect_to edit_rubric_url(@rubric), notice: 'Rubric was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @can_edit = @rubric.can_edit(current_user)
    # any user can see the edit form as it has a special readonly view
    @project = Project.id_and_title(@rubric.project)
    @projects = Project.visible_to_user(current_user).map {|p| Project.id_and_title(p)}
  end

  def update
    authorize! :update, @rubric
    simple_update(@rubric)
  end

  def destroy
    authorize! :destroy, @rubric
    @rubric.destroy
    redirect_to rubrics_url
  end

  def duplicate
    authorize! :duplicate, @rubric
    @new_rubric = @rubric.duplicate(current_user)

    if @new_rubric.save
      redirect_to edit_rubric_path(@new_rubric)
    else
      flash[:warning] = "Copy failed"
      redirect_to rubrics_path
    end
  end

  def export
    authorize! :export, @rubric
    rubric_json = @rubric.to_export_hash.to_json
    send_data rubric_json, type: :json, disposition: "attachment", filename: "#{@rubric.name}_version_2.json"
  end

  private

  def set_rubric
    @rubric = Rubric.find(params[:id])
  end

end
