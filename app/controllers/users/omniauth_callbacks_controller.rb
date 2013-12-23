class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def concord_portal
    omniauth = request.env["omniauth.auth"]
    if request.params['origin']
      provider_param = request.params['origin'].match /domain=([^\&]+)\&/
      omniauth.provider = Run.auth_provider(URI.decode(provider_param[1]))
    elsif ((request.referer.match /#{request.host}/) === nil) || request.host == 'localhost'
      omniauth.provider = Run.auth_provider(request.referer)
    end
    @user = User.find_for_concord_portal_oauth(omniauth, current_user)
    # TODO: Store portal signed in from?
    sign_in_and_redirect @user, :event => :authentication
  end
end
