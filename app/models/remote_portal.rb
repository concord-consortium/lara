class RemotePortal

  attr_accessor :remote_endpoint, :domain, :remote_id

  def initialize(params)
    self.remote_endpoint    = params[:returnUrl]
    self.domain             = params[:domain]
    self.remote_id          = params[:externalId]
  end

  def valid?
    # TODO: require domain
    return (self.remote_endpoint && self.remote_id)
  end

end