class ProcessPendingPortalPublication < Struct.new(:pending_portal_publication_id, :auto_publish_url, :backoff)
  def perform
    # immediately find and remove the pending publication so that new publications can be queued
    pending_portal_publication = PendingPortalPublication.find(pending_portal_publication_id)
    if pending_portal_publication.nil?
      info "no PendingPortalPublication"
      return
    end
    pending_portal_publication.delete

    # get shorter local references
    portal_publication = pending_portal_publication.portal_publication
    if portal_publication.nil?
      info "no PortalPublication"
      return
    end

    publishable = portal_publication.publishable
    if publishable.nil?
      info "no Publishable"
      return
    end

    portal = Concord::AuthPortal.portal_for_publishing_url(portal_publication.portal_url)
    if portal.nil?
      info "cannot find Portal for: #{portal_publication.portal_url}"
      return
    end

    last_portal_publication = publishable.last_publication(portal)
    if last_portal_publication.nil?
      info "no previous publication"
      return
    end

    # if the portal publication is not the latest one another job has published behind us so we are done
    if portal_publication.id != last_portal_publication.id
      info "successful publication happened since we were queued"
      return
    end

    # skip autopublish if the hash hasn't changed since the last publish
    json = publishable.serialize_for_portal(auto_publish_url).to_json
    if last_portal_publication.publication_hash == Digest::SHA1.hexdigest(json)
      info "publication_hash hasn't changed since last publish"
      return
    end

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

  # only attempt this job once, this way the last error will be meaningful
  # otherwise if an exception is thrown the PendingPortalPublication wont be recreated
  # the job will be retried but will fail right off the bat
  def max_attempts
    1
  end

  # if you want to seperately monitor the log statments from Jobs
  # first make sure you are running a seperate delayed_job process see:
  #    config/initializers/delayed_job_config.rb
  # then filter the messages in your log file
  #    tail -f log/development.log | grep "\[Job"
  # this is possible because of lib/delayed_job_tagged_logging.rb
  def info(text)
    Rails.logger.info text
  end
end
