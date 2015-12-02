class DashboardToc
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(activity)
    @activity = activity
    @pages = @activity.visible_pages_with_embeddables.map do |p|
      {
        name: p.name,
        id: p.id,
        url: activity_page_path(id: p.id, activity_id: @activity.id),
        embeddables: p.embeddables.map do |emb|
          type = emb.class.name.split("::").last.humanize
          { type: type }.merge(emb.to_hash)
        end
      }
    end
  end

  # Create a Table Of Contents for this activity
  def to_hash
    toc = {
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
