class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def concord_portal
    omniauth = request.env["omniauth.auth"]
    @user = User.find_for_concord_portal_oauth(omniauth, current_user)
    # TODO: Store portal signed in from?
    sign_in_and_redirect @user, :event => :authentication
  end
end
