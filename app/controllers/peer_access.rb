
module PeerAccess

protected
def get_auth_token(request)
  header = request.headers["Authorization"]
  if header && header =~ /^Bearer (.*)$/
    return $1
  end
  return ""
end

def verify_request_is_peer
  auth_token = get_auth_token(request)
  peer_tokens = Concord::AuthPortal.all.values.map { |c| c.secret }.uniq
  peer_tokens.include?(auth_token)
end

end