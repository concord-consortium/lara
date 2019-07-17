class SendToReportServiceJob < Struct.new(:publishable_type, :publishable_id, :queuetime)
  class FailedToSendToReportService < StandardError
  end

  def get_publishable()
    begin
      publishable_class = publishable_type.camelcase.constantize
      return publishable_class.find(publishable_id)
    rescue
      failmsg = "No publishable: #{publishable_type} #{publishable_id}"
      Rails.logger.error(failmsg)
      return false
    end
  end

  # If this function `perform` completes without error, our job will be removed
  # from the delayed Job queue. ( https://github.com/collectiveidea/delayed_job )
  # On error, the job is rescheduled in 5 seconds + N ** 4; N == number of tries
  def perform
    # Skip if the report service isn't configured. Removes from queue.
    return unless ReportService.configured?

    # Skip if we can't find the publishable. Removes from queue.
    publishable = get_publishable()
    return unless publishable

    # Skip if the publishable has changed since enqueuing. Removes from queue.
    # A new job will be scheduled. The new job should be run instead of this one.
    return if (publishable.updated_at > queuetime)
    resource_sender = ReportService::ResourceSender.new(publishable)

    # Skip it if nothing interesting changed. Removes from queue.
    return if (resource_sender.payload_hash == publishable.last_report_service_hash)

    result = resource_sender.send()
    
    if result["success"]
      # Record the last payload_hash to the publishable.
      publishable.update_column(:last_report_service_hash, resource_sender.payload_hash)
      # Success: If we made it to the end of our fuction this job will
      # be removed from delayed job queue.
    else
      # Delayed job automatically retries failed `perform`s.
      # rescheduled in 5 seconds + N ** 4
      raise FailedToSendToReportService.new("Failed to send")
    end
  end

  def max_attempts
    5
  end

end
