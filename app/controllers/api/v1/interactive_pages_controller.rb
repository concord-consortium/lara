class Api::V1::InteractivePagesController < API::APIController
  layout false
  before_filter :set_interactive_page, except: [
    :get_library_interactives_list,
    :get_pages,
    :create_page
  ]
  skip_before_filter :verify_authenticity_token

  ## Queries:
  def get_sections
    render_page_sections_json
  end

  # This is identical to get_sections. Why use different names?
  # Because it expresses the intent. Its possible we will want to return
  # different responses for each in the future.
  def get_page
    render_page_sections_json
  end

  def get_pages
    activity = LightweightActivity.find(params[:activity_id])
    return error("Can't find activity #{params[:activity_id]}") unless activity
    pages = activity.pages.map do |page|
      generate_page_json page
    end
    render :json => pages
  end

  ## Mutations
  def create_page
    activity = LightweightActivity.find(params[:activity_id])
    authorize! :update, activity
    return error("Can't find activity #{params[:activity_id]}") unless activity
    activity.pages.create()
    pages = activity.reload.pages.map do |page|
      generate_page_json page
    end
    render :json => pages
  end

  def delete_page
    activity = @interactive_page.lightweight_activity
    authorize! :update, activity
    @interactive_page.destroy
    render :json => ({success: true})
  end

  def set_sections
    param_sections = params['sections'] || [] # array of [{:id,:layout}]
    old_sections = @interactive_page.sections
    # Put them in the correct order:
    index = 1
    new_section_ids = param_sections.map { |s| s['id'] }
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

    # Remove deleted sections:
    old_sections.each do |section|
      unless (new_section_ids.include?(section.id.to_s))
        section.delete
      end
    end

    @interactive_page.sections = new_sections
    @interactive_page.save!
    render_page_sections_json
  end

  def create_section
    @interactive_page.add_section
    render_page_sections_json
  end

  def update_section
    authorize! :update, @interactive_page
    section_params = params['section']

    return error("Missing section parameter") if section_params.nil?
    return error("Missing section[:id] parameter") if section_params['id'].nil?

    section_id = section_params.delete('id')
    new_page_items = section_params.delete('items')
    section = Section.find(section_id)

    section.update_attributes(section_params)
    # Usually we will just be reordering the page_items within the section:
    if section && new_page_items
      new_page_items.each do |pi|
        page_item_id = pi.delete('id')
        page_item = PageItem.find(page_item_id)
        if page_item
          new_attr = { column: pi['column'], position: pi['position'] }
          page_item.update_attributes(new_attr)
        end
      end
    end
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
    column = page_item_params["column"] || PageItem::COLUMN_PRIMARY

    # currently we only support library interactives, this will change later
    case serializeable_id
    when /LibraryInteractive/
      library_interactive = LibraryInteractive.find_by_serializeable_id(serializeable_id)
      return error("Invalid page_item[embeddable] parameter") if library_interactive.nil?
      embeddable = ManagedInteractive.create!(library_interactive_id: library_interactive.id)
    when /MwInteractive/
      embeddable = MwInteractive.create!
    else
      return error("Only library interactive embeddables are currently supported")
    end

    @interactive_page.add_embeddable(embeddable, position, section.id, column)
    @interactive_page.reload

    render_page_sections_json
  end

  def get_library_interactives_list
    library_interactives = LibraryInteractive
      .select("library_interactives.id, library_interactives.name, count(managed_interactives.id) as use_count, UNIX_TIMESTAMP(library_interactives.created_at) as date_added")
      .joins("LEFT JOIN managed_interactives ON managed_interactives.linked_interactive_id = library_interactives.id")
      .group('library_interactives.id').map do |li|
        {id: li.serializeable_id, name: li.name, use_count: li.use_count, date_added: li.date_added }
      end

    render :json => {
      success: true,
      library_interactives: library_interactives
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
        layout: s.layout,
        items: s.page_items.map do |pi|
          {
            id: pi.id.to_s,
            column: pi.column,
            position: pi.position,
            type: pi.embeddable_type,
            data: pi.embeddable.respond_to?(:to_interactive) ? pi.embeddable.to_interactive : pi.embeddable.to_hash
          }
        end
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
