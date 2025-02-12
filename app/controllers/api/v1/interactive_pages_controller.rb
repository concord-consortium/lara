class Api::V1::InteractivePagesController < Api::ApiController
  layout false
  before_action :set_interactive_page, except: [
    :get_library_interactives_list,
    :get_wrapping_plugins_list,
    :get_portal_list,
    :get_pages,
    :create_page
  ]
  skip_before_action :verify_authenticity_token

  ## Queries:
  def get_sections
    render_page_sections_json
  end

  def get_preview_url
    page = @interactive_page
    activity = page.lightweight_activity
    render json: view_context.activity_preview_options(activity, page)
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
    render json: pages
  end

  ## Mutations
  def copy_page
    activity = @interactive_page.lightweight_activity
    authorize! :update, activity
    return error("Can't find required parameter 'dest_index'") unless params[:dest_index]
    return error("Can't find activity for page") unless activity
    position = params[:dest_index]
    next_page = @interactive_page.duplicate
    next_page.lightweight_activity = activity
    next_page.set_list_position(position)
    activity.reload
    next_page.reload
    update_activity_changed_by(activity)
    render json: generate_page_json(next_page)
  end

  def create_page
    activity = LightweightActivity.find(params[:activity_id])
    authorize! :update, activity
    return error("Can't find activity #{params[:activity_id]}") unless activity
    activity.pages.create()
    last_idx = activity.pages.length - 1
    prev_last_idx = activity.pages.length - 2
    if activity.pages[prev_last_idx].is_completion
      activity.pages[prev_last_idx].position = last_idx
      activity.pages[prev_last_idx].move_lower
    end

    pages = activity.reload.pages.map do |page|
      page.reload
      generate_page_json page
    end
    update_activity_changed_by(activity)
    render json: pages
  end

  def delete_page
    activity = @interactive_page.lightweight_activity
    authorize! :update, activity
    @interactive_page.destroy
    update_activity_changed_by(activity)
    render json: ({success: true})
  end

  def update_page
    activity = @interactive_page.lightweight_activity
    authorize! :update, activity, @interactive_page
    page_params = params.require("page").permit(:name, :isCompletion, :isHidden, :showSidebar, :sidebar, :sidebarTitle)
    return error("Missing page parameter") if page_params.nil?

    if page_params
      change_keys = 'name is_completion is_hidden show_sidebar sidebar sidebar_title'.split
      # Limit the parameters we accept here, remove nil values, and convert
      # snake case to underscore.
      clean_params = page_params.to_h.map { |key, value| [key.to_s.underscore, value] }
      clean_params = clean_params.reject { |k, v| v.nil? }
      clean_params = clean_params.select { |k, v| change_keys.include?(k) }
      @interactive_page.update(clean_params.to_h)

      if page_params['isCompletion']
        @interactive_page.move_to_bottom
      end
    end
    @interactive_page.save!
    pages = activity.reload.pages.map do |page|
      generate_page_json page
    end
    update_activity_changed_by(activity)
    render json: pages
  end

  def set_sections
    authorize! :update, @interactive_page
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
      index += 1
      section
    end

    # Remove deleted sections:
    old_sections.each do |section|
      unless (new_section_ids.include?(section.id.to_s))
        section.update_attribute(:interactive_page_id, nil)
      end
    end

    @interactive_page.sections = new_sections
    @interactive_page.save!
    update_activity_changed_by(@interactive_page.lightweight_activity)
    render_page_sections_json
  end

  def create_section
    @interactive_page.add_section
    render_page_sections_json
  end

  def copy_section
    authorize! :update, @interactive_page
    section_id = params['section_id']
    return error("Missing section parameter") if section_id.nil?

    section = @interactive_page.sections.find(section_id)
    section.duplicate
    update_activity_changed_by(@interactive_page.lightweight_activity)
    render_page_sections_json
  end

  def copy_page_item
    authorize! :update, @interactive_page
    item_id = params['page_item_id']
    return error("Missing page_item_id parameter") if item_id.nil?

    item = @interactive_page.page_items.find { |i| i.id == item_id.to_i }
    duplicate = item.duplicate
    update_activity_changed_by(@interactive_page.lightweight_activity)
    render json: generate_item_json(duplicate)
  end

  def safe_section_params
    params.require(:section).permit(
      :can_collapse_small, :id, :layout, :name, :position, :show,
      items: [:id, :position, :column]
    )
  end

  def update_section
    authorize! :update, @interactive_page
    section_params = safe_section_params

    return error("Missing section parameter") if section_params.nil?
    return error("Missing section[:id] parameter") if section_params['id'].nil?

    section_id = section_params.delete('id')
    section = Section.find(section_id)
    new_items = section_params.delete('items')
    new_item_ids = new_items&.map { |i| i['id'] }
    old_items = section.page_items
    section.update(section_params)

    # Its OK for update_section to come in without items...
    if new_items.present?
      new_item_ids.compact! # remove nil items
      # Usually we will just be reordering the page_items within the section:
      if section && new_items
        new_items.each do |pi|
          page_item = PageItem.find(pi.delete('id'))
          page_item&.update({
              column: pi['column'],
              position: pi['position'],
              section: section
            })
        end
      end
    end

    # remove any missing items...
    if new_item_ids && !new_item_ids.empty?
      old_items.each do |item|
        item.update({ section: nil }) unless new_item_ids.include?(item.id.to_s)
      end
    end
    update_activity_changed_by(@interactive_page.lightweight_activity)
    render_page_sections_json
  end

  def create_page_item_params
    params.require(:page_item).permit(
      :section_id, :section, :position, :embeddable, :column,
      :type, :wrapped_embeddable_id, :wrapped_embeddable_type
    )
  end

  def create_page_item
    authorize! :update, @interactive_page

    return error("Missing page_item parameter") if params[:page_item].nil?

    # verify the parameters
    section_id = params[:page_item]["section_id"]
    return error("Missing page_item[section_id] parameter") if section_id.nil?
    section = @interactive_page.sections.where(id: section_id).first
    return error("Invalid page_item[section_id] parameter") if section.nil?
    embeddable_type = params[:page_item]["embeddable"]
    return error("Missing page_item[embeddable] parameter") if embeddable_type.nil?
    position = params[:page_item]["position"]
    position = position.to_i unless position.nil?
    column = params[:page_item]["column"] || PageItem::COLUMN_PRIMARY

    # currently we only support library interactives, iframe interactives, and text blocks, this will change later
    case embeddable_type
    when /LibraryInteractive/
      library_interactive = LibraryInteractive.find_by_serializeable_id(embeddable_type)
      return error("Invalid page_item[embeddable] parameter") if library_interactive.nil?

      embeddable = ManagedInteractive.create!(library_interactive_id: library_interactive.id)
    when /MwInteractive/
      embeddable = MwInteractive.create!
    when /Embeddable::Xhtml/
      embeddable = Embeddable::Xhtml.create!
    when /Plugin_(\d+)::(.*)/
      # Parse the embeddable_type string to get the approved_script id.
      # For plugin items we need to create a new embeddable of type
      # Embeddable::Plugin and then associate it with the plugin.
      # 1. Create a plugin with the instance of the approved_script
      # 2. Create a Embeddable::EmbeddablePlugin
      # Example: "Plugin_10::windowShade"
      # IMPORTANT: The tip type, "windowShade" in the above example, as
      # the component_label is critical.
      tip_type = $2
      regex = /Plugin_(\d+)::#{tip_type}/
      script_id = embeddable_type.match(regex)[1]
      author_data = { tipType: tip_type }.to_json
      wrapped_embeddable_id = params[:page_item]["wrapped_embeddable_id"]
      wrapped_embeddable_type = params[:page_item]["wrapped_embeddable_type"]
      # I am following the convention I saw in interactive_pages_controller.rb
      embeddable = Embeddable::EmbeddablePlugin.create!
      embeddable.approved_script_id = script_id
      embeddable.author_data = author_data
      embeddable.component_label = tip_type
      embeddable.is_half_width = false
      if wrapped_embeddable_id && wrapped_embeddable_type
        embeddable.embeddable_id = wrapped_embeddable_id
        embeddable.embeddable_type = wrapped_embeddable_type
      end
      embeddable.save!
    else
      return error("Unknown embbeddable_type: #{embeddable_type}\nOnly library interactive embeddables, iFrame interactives, and text blocks are currently supported")
    end

    @interactive_page.add_embeddable(embeddable, position, section, column)
    @interactive_page.reload

    embeddable.reload
    pi = embeddable.p_item
    result = {
      id: pi.id.to_s,
      column: pi.column,
      position: pi.position,
      type: pi.embeddable_type,
      data: pi.embeddable.to_hash # using pi.embeddable.to_interactive here broke editing/saving by sending unnecessary/incorrect data back
    }
    update_activity_changed_by(@interactive_page.lightweight_activity)
    render json: result.to_json
  end

  def update_page_params
    params.require(:page_item).permit(
      :section, :position, :embeddable, :column, :data
    )
  end

  def data_update_params
    params[:page_item].require(:data).permit(
      :aspect_ratio_method,
      :author_data,
      :authored_state,
      :click_to_play,
      :click_to_play_prompt,
      :component_label,
      :content,
      :custom_aspect_ratio_method,
      :custom_click_to_play,
      :custom_click_to_play_prompt,
      :custom_full_window,
      :custom_hide_question_number,
      :custom_image_url,
      :custom_native_height,
      :custom_native_width,
      :enable_learner_state,
      :full_window,
      :has_report_url,
      :hide_question_number,
      :inherit_aspect_ratio_method,
      :inherit_click_to_play,
      :inherit_click_to_play_prompt,
      :inherit_full_window,
      :inherit_hide_question_number,
      :inherit_native_height,
      :inherit_native_width,
      :inherit_image_url,
      :image_url,
      :is_callout,
      :is_half_width,
      :is_hidden,
      :label,
      :legacy_ref_id,
      :legacy_ref_type,
      :library_interactive_id,
      :linked_interactive_id,
      :linked_interactive_item_id,
      :linked_interactive_type,
      :linked_interactives,
      :model_library_url,
      :name,
      :native_height,
      :native_width,
      :no_snapshots,
      :report_item_url,
      :show_delete_data_button,
      :url,
      :url_fragment
    )
  end

  def update_page_item
    authorize! :update, @interactive_page

    return error("Missing page_item parameter") if params[:page_item].nil?

    # verify the parameters
    page_item_id = params[:page_item]["id"]
    return error("Missing page_item[id] parameter") if page_item_id.nil?
    column = params[:page_item]["column"]
    return error("Missing page_item[column] parameter") if column.nil?
    position = params[:page_item]["position"]
    return error("Missing page_item[position] parameter") if position.nil?
    data = params[:page_item]["data"]
    return error("Missing page_item[data] parameter") if data.nil?
    type = params[:page_item]["type"]
    return error("Missing page_item[type] parameter") if type.nil?

    page_item = PageItem.find(page_item_id)
    if page_item
      page_item.update(update_page_params)
      embeddable_type = type.constantize
      embeddable = embeddable_type.find(page_item.embeddable_id)
      # linked_interactives param follows ISetLinkedInteractives interface format. It isn't a regular attribute.
      # It requires special treatment and should be removed from params before .update is called.
      if data.has_key? :linked_interactives
        linked_interactives = data.delete :linked_interactives
        if linked_interactives.present?
          page_item.set_linked_interactives(JSON.parse(linked_interactives))
        end
      end
      if embeddable
        embeddable.update(data_update_params)
      end
    end
    @interactive_page.reload
    update_activity_changed_by(@interactive_page.lightweight_activity)
    render json: embeddable_to_edit_hash(embeddable).to_json
  end

  def delete_page_item
    authorize! :update, @interactive_page

    page_item_id = params["page_item_id"]
    return error("Missing page_item_id parameter") if page_item_id.nil?
    changed = false

    # The page_item must be in the current page:
    @interactive_page.page_items.each do |page_item|
      if page_item.id.to_s == page_item_id.to_s
        changed = true
        page_item.destroy
      end
    end
    @interactive_page.reload if changed
    update_activity_changed_by(@interactive_page.lightweight_activity) if changed
    render_page_sections_json
  end

  def get_portal_list
    portals = []
    Concord::AuthPortal.all.each_pair do |key, portal|
      name = portal.link_name
      path = user_omniauth_authorize_path(portal.strategy_name)
      portals.push({name: name, path: path})
    end

    render json: {
      success: true,
      portals: portals
    }
  end

  def get_wrapping_plugins_list
    plugins = []
    available_plugins = ApprovedScript.authoring_menu_items("embeddable-decoration")
    available_plugins.each do |plugin|
      component_label = plugin.component_label
      component_name = plugin.component_name
      id = plugin.approved_script_id
      name = plugin.name
      plugins.push({
        component_label: component_label,
        component_name: component_name,
        id: id,
        name: name
      })
    end

    render json: {
      success: true,
      plugins: plugins
    }
  end

  private
  def get_teacher_edition_plugins
    required_version = [3]
    required_label = ["teacherEditionTips"]
    ApprovedScript.where(version: required_version, label: required_label)
  end

  private
  def map_plugin_to_hash(plugin)
    {
      id: plugin.id,
      name: plugin.name,
      label: plugin.label,
      description: plugin.description,
      version: plugin.version,
      authoring_metadata: JSON.parse(plugin.authoring_metadata)
    }
  end

  public
  def get_library_interactives_list
    library_interactives = LibraryInteractive
      .select("library_interactives.*, CONCAT('LibraryInteractive_', library_interactives.id) as serializeable_id, count(managed_interactives.id) as query_use_count, UNIX_TIMESTAMP(library_interactives.created_at) as date_added")
      .joins("LEFT JOIN managed_interactives ON managed_interactives.library_interactive_id = library_interactives.id")
      .group('library_interactives.id')

    plugins = get_teacher_edition_plugins.map { |plugin| map_plugin_to_hash(plugin) }

    library_interactives_list = library_interactives.map do |library_interactive|
      li_json = library_interactive.as_json
      li_json["use_count"] = li_json["query_use_count"]
      li_json.delete("query_use_count")
      li_json
    end

    render json: {
      success: true,
      library_interactives: library_interactives_list,
      plugins: plugins
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
            embeddableId: pi.embeddable_id,
            pageId: @interactive_page.id,
            name: i.name,
            section: pi.section != nil ? pi.section.title : Section::DEFAULT_SECTION_TITLE,
            url: i.url,
            thumbnailUrl: i.thumbnail_url,
            supportsSnapshots: !i.no_snapshots
          }
        end

      render json: { success: true, interactives: interactives}

    rescue CanCan::AccessDenied
      return render json: { success: false, message: "You are not authorized to get the interactive list from the requested page"}
    rescue => error
      return render json: { success: false, message: error.message}
    end
  end

  private
  def generate_item_json(page_item)
    embeddable = page_item.embeddable
    if (embeddable.nil?)
      return { error: "WARNING: page_item #{page_item.id} has no embeddable" }
    end
    embeddable_to_edit_hash(embeddable)
  end

  def generate_section_json(section)
    {
      can_collapse_small: section.can_collapse_small,
      id: section.id.to_s,
      items: section.page_items.map { |pi| generate_item_json(pi) },
      layout: section.layout,
      name: section.name,
      position: section.position,
      show: section.show
    }
  end

  def generate_page_json(page)
    sections = page.sections.map { |s| generate_section_json(s) }
    {
      id: page.id.to_s,
      name: page.name,
      isCompletion: page.is_completion,
      isHidden: page.is_hidden,
      showSidebar: page.show_sidebar,
      sidebar: page.sidebar,
      sidebarTitle: page.sidebar_title,
      position: page.position,
      sections: sections
    }
  end

  def render_page_sections_json(page=@interactive)
    render json: generate_page_json(@interactive_page)
  end

  def set_interactive_page
    begin
      @interactive_page = InteractivePage.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, message: "Could not find interactive page ##{params['id']}"}
    end
  end

  def embeddable_to_edit_hash(embeddable)
    embeddable.reload
    pi = embeddable.p_item
    e = pi.embeddable
    # EM & NP ~2021: using pi.embeddable.to_interactive here broke editing/saving
    #   by sending unnecessary/incorrect data back
    data_hash = e.to_hash

    # NP 2022-05-27: we need to allow embeddables to customize their editing
    #   hash
    data_hash = e.to_editing_hash if e.respond_to?(:to_editing_hash)

    {
      id: pi.id.to_s,
      column: pi.column,
      position: pi.position,
      type: pi.embeddable_type,
      data: data_hash,
      authoring_api_urls: embeddable.respond_to?(:authoring_api_urls) ? embeddable.authoring_api_urls(request.protocol, request.host_with_port) : {}
    }
  end
end
