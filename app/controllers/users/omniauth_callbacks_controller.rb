class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def concord_portal
    omniauth = request.env["omniauth.auth"] # Can this object have multiple portal options?
    @user = User.find_for_concord_portal_oauth(omniauth, current_user)
    sign_in_and_redirect @user, :event => :authentication
  end
end
