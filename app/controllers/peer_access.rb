module PeerAccess

  def self.included klass
    klass.class_eval do
      skip_before_action :verify_authenticity_token, if: :verified_json_request?
    end
  end

  protected

  def get_auth_token(request)
    header = request.headers["HTTP_AUTHORIZATION"] || request.headers["Authorization"] || request.headers["authorization"]
    if header && header =~ /^Bearer (.*)$/
      return $1
    end
  end

  def verified_json_request?
    auth_token = get_auth_token(request)
    peer_tokens = Concord::AuthPortal.all.values.map {|c| c.secret}.uniq
    peer_tokens.include?(auth_token)
  end

  def authorize_peer!
    raise CanCan::AccessDenied unless verified_json_request?
  end
end
