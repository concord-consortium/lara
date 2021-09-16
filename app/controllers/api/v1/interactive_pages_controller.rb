class Api::V1::InteractivePagesController < API::APIController
  layout false
  before_filter :set_interactive_page, except: [:get_library_interactives_list]

  ## Queries:
  def get_sections
    render_page_sections_json
  end

  def get_pages
    activity = @interactive_page.lightweight_activity
    pages = activity.pages.map do |page|
      generate_page_json page
    end
    render :json => pages
  end

  ## Mutations
  def set_sections
    param_sections = params['sections'] # array of [{:id,:layout}]
    old_sections = @interactive_page.sections
    # Put them in the correct order:
    index = 1
    new_sections = param_sections.map do |s|
      section = Section.find(s['id'])
      position = index
      if section.position != position
        section.position = position
        section.save!(validate: false)
      end
      index = index + 1
      section
    end
    # TBD: Remove 'unused' sections?
    # sections.to_remove = old_sections.filter { |s| s.id != }
    @interactive_page.sections = new_sections
    @interactive_page.save!
    render_page_sections_json
  end

  def create_section
    @interactive_page.add_section
    render_page_sections_json
  end

  def update_section
    section_params = params['section']
    section_id = section_params.delete('id')
    section = Section.find(section_id)
    section.update_attributes(section_params)
    render_page_sections_json
  end

  def create_page_item
    authorize! :update, @interactive_page

    page_item_params = params["page_item"]
    return error("Missing page_item parameter") if page_item_params.nil?

    # verify the parameters
    section_id = page_item_params["section_id"]
    return error("Missing page_item[section_id] parameter") if section_id.nil?
    section = @interactive_page.sections.where(id: section_id).first
    return error("Invalid page_item[section_id] parameter") if section.nil?
    serializeable_id = page_item_params["embeddable"]
    return error("Missing page_item[embeddable] parameter") if serializeable_id.nil?
    position = page_item_params["position"]
    position = position.to_i unless position.nil?

    # currently we only support library interactives, this will change later
    if serializeable_id.start_with?("LibraryInteractive")
      library_interactive = LibraryInteractive.find_by_serializeable_id(serializeable_id)
      return error("Invalid page_item[embeddable] parameter") if library_interactive.nil?
      embeddable = ManagedInteractive.create(library_interactive_id: library_interactive.id)
    else
      return error("Only library interactive embeddables are currently supported")
    end

    @interactive_page.add_embeddable(embeddable, position, section.id)

    # TODO: in follow on work change the returned json to include the page items
    render_page_sections_json
  end

  def get_library_interactives_list
    render :json => {
      success: true,
      library_interactives: LibraryInteractive.select([:id, :name]).order(:name).map do |li|
        {id: li.serializeable_id, name: li.name }
      end
    }
  end

  def get_interactive_list
    begin
      authorize! :read, @interactive_page

      scope = params[:scope] || "page"
      supports_snapshots = params[:supportsSnapshots]

      if scope != "page"
        raise "Invalid scope parameter: #{scope}"
      end

      interactives = @interactive_page
        .interactive_page_items
        .select do |pi|
          i = pi.embeddable
          case supports_snapshots
          when "true"
            !i.no_snapshots
          when "false"
            i.no_snapshots
          else
            # supportsSnapshots is optional
            true
          end
        end
        .map do |pi|
          i = pi.embeddable
          {
            id: "interactive_#{pi.id}",
            pageId: @interactive_page.id,
            name: i.name,
            section: pi.section != nil ? pi.section.title : Section::DEFAULT_SECTION_TITLE,
            url: i.url,
            thumbnailUrl: i.thumbnail_url,
            supportsSnapshots: !i.no_snapshots
          }
        end

      render :json => { :success => true, interactives: interactives}

    rescue CanCan::AccessDenied
      return render :json => { :success => false, :message => "You are not authorized to get the interactive list from the requested page"}
    rescue => error
      return render :json => { :success => false, :message => error.message}
    end
  end

  private

  def generate_page_json(page)
    sections = page.sections.map do |s|
      {
        id: s.id.to_s,
        layout: s.layout
      }
    end
    return {
      id: page.id,
      title: page.name,
      sections: sections
    }
  end

  def render_page_sections_json(page=@interactive)
    render :json => generate_page_json(@interactive_page)
  end

  def set_interactive_page
    begin
      @interactive_page = InteractivePage.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render :json => { :success => false, :message => "Could not find interactive page ##{params['id']}"}
    end
  end
end
