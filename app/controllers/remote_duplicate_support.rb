module RemoteDuplicateSupport

  def self.included klass
    klass.class_eval do
      # Include PeerAccess module so authorize_peer! method is available.
      # It checks whether request is coming from trusted Portal instance.
      include PeerAccess
    end
  end

  # Action triggered by Portal. Duplicates an activity or sequence and returns its publication data.
  # It excepts @activity or @sequence to be available.
  def remote_duplicate
    authorize_peer!
    request_json = JSON.parse(request.body.read, symbolize_names: true)

    resource = @activity || @sequence

    # Make sure that user exists. It might not if he never opened LARA before and it's just copying an activity using Portal.
    user = User.find_by_email request_json[:user_email]
    unless user
      user = User.create(
        email: request_json[:user_email],
        password: User.get_random_password,
        is_author: true
      )
    end

    new_resource = resource.duplicate(user)

    if new_resource.save(validations: false) # in case the old resource was invalid
      self_url = "#{request.protocol}#{request.host_with_port}"
      publication_data = new_resource.serialize_for_portal(self_url)
      # We need to manually create publication data. Since this path is a bit different than typical,
      # not all the field make so much sense. Also, we don't get response from Portal whether it has been
      # successful or not, so we have to assume it was.
      auth_portal = Concord::AuthPortal.portal_for_url(params['add_to_portal'])
      new_resource.portal_publications.create({
        portal_url: auth_portal.publishing_url,
        sent_data: publication_data,
        response: nil,
        success: true,
        publishable: new_resource,
        publication_hash: publication_data,
        publication_time: nil
      })
      render status: 200, json: { publication_data: publication_data }, content_type: 'text/json'
    else
      render status: 500, json: { error: "Remote duplicate failed" }, content_type: 'text/json'
    end
  end
end
