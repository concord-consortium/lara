module ConcordPortalPublishing


  # publish an activity or sequence to the portal
  def portal_publish(publishable)

    # TODO: better error handling
    raise "#{publishable.class.name} is Not Publishable" unless publishable.respond_to?(:serialize_for_portal)

    logger.info "Attempting to publish #{publishable.class.name} #{publishable.id} to #{portal_url}."
    auth_token = 'Bearer %s' % current_user.authentication_token
    response = HTTParty.post(portal_url,
      :body => publishable.serialize_for_portal("#{request.protocol}#{request.host_with_port}").to_json,
      :headers => {"Authorization" => auth_token, "Content-Type" => 'application/json'})

    # report success or put details in flash
    logger.info "Response: #{response.inspect}"
    # TODO: add a publication record to the publishable
    publishable.portal_publications.create({
      portal_url: portal_url,
      response: response.inspect,
      success: ( response.code == 201 ) ? true : false,
      publishable: publishable
    })

    if response.code == 201
      return true
    else
      flash[:alert] = "Got response code #{response.code} from the portal: #{response.message}"
      return false
    end

  end
end
