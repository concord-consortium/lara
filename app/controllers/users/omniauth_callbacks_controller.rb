class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def concord_portal
    omniauth = request.env["omniauth.auth"] # Can this object have multiple portal options?
    @user = User.find_for_concord_portal_oauth(omniauth, current_user)
    sign_in_and_redirect @user, event: :authentication
  end
  Concord::AuthPortal.all.each_pair do |key, portal|
    # dynamically create the controller action for this strategy see concord/auth_portal.rb
    class_eval portal.controller_action
  end 

  # NOTE: it can be handy to setup debug points for these methods action_missing(provider) and passthru(provider)
end
