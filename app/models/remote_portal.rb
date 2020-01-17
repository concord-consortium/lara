class RemotePortal

  attr_accessor :remote_endpoint, :domain, :remote_id, :platform_info

  def initialize(params)
    self.remote_endpoint    = params[:returnUrl]
    self.domain             = params[:domain]
    self.remote_id          = params[:externalId]
    self.platform_info = params.slice(:platform_id, :platform_user_id, :resource_link_id, :context_id, :class_info_url)
  end

  def valid?
    # TODO: require domain
    return (self.remote_endpoint && self.remote_id)
  end

end
