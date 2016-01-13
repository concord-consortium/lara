class DashboardToc
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(activity)
    @activity = activity
    @pages = @activity.visible_pages_with_embeddables.map do |p|
      {
        name: p.name,
        id: p.id,
        url: activity_page_path(id: p.id, activity_id: @activity.id),
        questions: questions(p)
      }
    end
  end

  def questions(page)
    questions = page.section_embeddables(CRater::ARG_SECTION_NAME).map do |q|
      {
          index: q.index_in_activity(page.lightweight_activity),
          name: q.name,
          prompt: q.prompt
      }
    end
    questions.sort! { |a,b| a[:index] <=> b[:index] }
  end

  # Create a Table Of Contents for this activity
  def to_hash
    {
      name: @activity.name,
      url: activity_path(id: @activity.id),
      id: @activity.id,
      pages: @pages
    }
  end

  def to_json
    to_hash.to_json
  end

end
