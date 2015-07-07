class ProcessPendingPortalPublication < Struct.new(:pending_portal_publication_id, :auto_publish_url, :backoff)
  def perform
    # immediately find and remove the pending publication so that new publications can be queued
    pending_portal_publication = PendingPortalPublication.find(pending_portal_publication_id)
    return if pending_portal_publication.nil?
    pending_portal_publication.delete

    # get shorter local references
    portal_publication = pending_portal_publication.portal_publication
    return if portal_publication.nil?
    publishable = portal_publication.publishable
    return if publishable.nil?
    portal = Concord::AuthPortal.portal_for_publishing_url(portal_publication.portal_url)
    last_portal_publication = publishable.last_publication(portal)
    return if last_portal_publication.nil?

    # if the portal publication is not the latest one another job has published behind us so we are done
    return if portal_publication.id != last_portal_publication.id

    # skip autopublish if the hash hasn't changed since the last publish
    json = publishable.serialize_for_portal(auto_publish_url).to_json
    return if last_portal_publication.publication_hash == Digest::SHA1.hexdigest(json)

    # publish to the portal
    response = publishable.republish_for_portal(portal, auto_publish_url, json)
    unless response.code == 201

      # if it fails requeue with an exponentially increased backoff time with a max of 3 hours or 10800 seconds
      # will actually stop at (2^11)*5=10240 seconds or 2.84 hours
      new_backoff = backoff * 2
      if new_backoff * publishable.auto_publish_delay < 3*60*60
        publishable.queue_auto_publish_to_portal(auto_publish_url, new_backoff)
      end
    end
  end

  def debug(text)
    Delayed::Worker.logger.add(Logger::DEBUG, text) if Delayed::Worker.logger
  end
end
