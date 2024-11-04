class PublicationDetails
  include LightweightStandalone::Application.routes.url_helpers

  def initialize(publication)
    @publication = publication
  end

  def to_json
    {
      last_publication_hash: @publication.publication_hash,
      latest_publication_portals: @publication.latest_publication_portals,
      publish_url: publication_publish_to_other_portals_path(@publication.class, @publication.id),
      poll_url: publication_autopublishing_status_path(@publication.class, @publication.id)
    }
  end
end
