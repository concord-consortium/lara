class ITSIAuthoring::Editor
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(activity)
    @activity = activity
  end

  def to_json
    {
      metadata: metadata_json,
      sections: @activity.pages
        .includes(sections: :page_items)
        .map { |p| section_json(p) },
      active_runs: @activity.active_runs,
      publication_details: {
        :last_publication_hash => @activity.publication_hash,
        :latest_publication_portals => @activity.latest_publication_portals,
        :publish_url => publication_publish_to_other_portals_path(@activity.class, @activity.id),
        :poll_url => publication_autopublishing_status_path(@activity.class, @activity.id)
      },
      json_list_urls: {
        models: ENV['MODEL_JSON_LIST_URL'],
        sensor_predictions: ENV['SENSOR_PREDICTION_JSON_LIST_URL']
      }
    }
  end

  private

  def metadata_json
    {
      name: @activity.name,
      description: @activity.description,
      update_url: activity_path(@activity)
    }
  end

  def section_json(page)
    {
      name: page.name,
      is_hidden: page.is_hidden,
      update_url: interactive_page_path(page),
      interactives: page.section_embeddables(InteractivePage::INTERACTIVE_BOX).map { |i| interactive_json(i, page) },
      embeddables: page.embeddables.select { |e| e.page_section.nil? }
                                   .map { |e| embeddable_json(e) },
      header_embeddables: page.embeddables.select { |e| e.page_section == InteractivePage::HEADER_BLOCK }
                                          .map { |he| embeddable_json(he) }
    }
  end

  def embeddable_json(e)
    type = e.class.name.underscore.gsub('embeddable/', '') # e.g. embeddable/open_response -> open_response
    case type
      when 'open_response'
        open_response_json(e)
      when 'xhtml'
        xhtml_json(e)
      when 'image_question'
        image_question_json(e)
      when 'managed_interactive'
        managed_interactive_json(e)
      else
        {}
    end
  end

  def open_response_json(e)
    {
      type: 'open_response',
      name: e.name,
      prompt: e.prompt,
      is_hidden: e.is_hidden,
      default_text: e.default_text,
      update_url: embeddable_open_response_path(e)
    }
  end

  def xhtml_json(e)
    {
      type: 'xhtml',
      name: e.name,
      is_hidden: e.is_hidden,
      content: e.content,
      update_url: embeddable_xhtml_path(e)
    }
  end

  def image_question_json(e)
    {
      type: 'image_question',
      name: e.name,
      prompt: e.prompt,
      is_hidden: e.is_hidden,
      bg_url: e.bg_url,
      update_url: embeddable_image_question_path(e)
    }
  end

  def interactive_json(i, page)
    type = i.class.name.underscore
    case type
      when 'mw_interactive'
        # In fact MwInteractive is a simple iframe.
        iframe_interactive_json(i, page)
      when 'managed_interactive'
        managed_interactive_json(i)
      else
        # Other interactive types aren't supported by ITSI editor anyway.
        {}
    end
  end

  def iframe_interactive_json(i, page)
    {
      type: 'iframe_interactive',
      name: i.name,
      is_hidden: i.is_hidden,
      url: i.url,
      image_url: i.image_url,
      model_library_url: i.model_library_url,
      authored_state: i.authored_state,
      update_url: mw_interactive_path(i)
    }
  end

  def managed_interactive_json(i)
    {
      type: 'managed_interactive',
      name: i.library_interactive&.name,
      is_hidden: i.is_hidden,
      url: i.url,
      authored_state: i.authored_state,
      update_url: managed_interactive_path(i)
    }
  end
end
