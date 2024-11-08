module CustomPathPatch
  # this was removed in the OmniAuth gem
  def user_omniauth_authorize_path(strategy_name, origin: nil)
    base_path = "/users/auth/#{strategy_name}"

    # Append the custom `origin` parameter if provided
    if origin
      uri = URI(base_path)
      uri.query = URI.encode_www_form((URI.decode_www_form(uri.query || '') + [['origin', origin]]).to_h)
      uri.to_s
    else
      base_path
    end
  end
end

# Inject the monkey patch into Rails' URL helpers
Rails.application.routes.named_routes.url_helpers_module.prepend(CustomPathPatch)
