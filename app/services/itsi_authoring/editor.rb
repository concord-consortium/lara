class ITSIAuthoring::Editor
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(activity)
    @activity = activity
  end

  def to_json
    {
      metadata: metadata_json,
      sections: @activity.pages.map { |p| section_json(p) }
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
      text: page.text, # introduction text
      is_hidden: page.is_hidden,
      update_url: interactive_page_path(page),
      interactives: page.interactives.map { |i| interactive_json(i, page) },
      embeddables: page.embeddables.map { |e| embeddable_json(e) }
    }
  end

  def embeddable_json(e)
    type = e.class.name.underscore.gsub('embeddable/', '') # e.g. embeddable/open_response -> open_response
    case type
      when 'open_response'
        open_response_json(e)
      when 'image_question'
        image_question_json(e)
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
      update_url: embeddable_open_response_path(e)
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
      else
        # Other interactive types aren't supported by ITSI editor anyway.
        {}
    end
  end

  def iframe_interactive_json(i, page)
    {
      type: 'iframe_interactive',
      name: i.name,
      url: i.url,
      image_url: i.image_url,
      update_url: page_mw_interactive_path(page, i)
    }
  end
end
