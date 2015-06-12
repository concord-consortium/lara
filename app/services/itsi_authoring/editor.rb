class ITSIAuthoring::Editor
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(activity)
    @activity = activity
  end

  def to_json
    {
      paths: paths_json,
      metadata: metadata_json,
      sections: sections_json
    }
  end

  private

  def paths_json
    {
      activity: activity_path(@activity)
    }
  end

  def metadata_json
    {
      name: @activity.name,
      description: @activity.description
    }
  end

  def sections_json
    @activity.pages.each do |p|
      {}
    end
  end
end
