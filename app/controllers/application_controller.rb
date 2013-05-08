class ApplicationController < ActionController::Base
  # Run authorization on all actions
  # check_authorization
  protect_from_forgery

  # What to do if authorization fails
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_url, :alert => exception.message
  end

  # For modal edit windows. Source: https://gist.github.com/1456815
  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }

  def update_activity_changed_by
    @activity.changed_by = current_user
    begin
      @activity.save
    rescue
    end
  end

  protected

  def update_portal_session
    if params[:domain] && params[:externalId]
      session[:auth_return_url] = request.url
      unless session[:did_reauthenticate]
        session[:did_reauthenticate] = true
        sign_out(current_user)
        redirect_to user_omniauth_authorize_path(:concord_portal)
      end
    end
  end

  def update_anonymous_session
    session[:response_key] ||= {}
    if params[:response_key]
      session[:response_key][@activity.id] = params[:response_key]
    end
    @session_key = session[:response_key][@activity.id]
  end

  def set_run_key
    update_anonymous_session if current_user.nil?
    update_portal_session unless session.delete(:did_reauthenticate)
    portal = RemotePortal.new(params)
    @run = Run.lookup(@session_key, @activity, current_user, portal)
    @session_key = @run.key
  end

  # override devise's built in method so we can go back to the path
  # from which authentication was initiated
  def after_sign_in_path_for(resource)
    session.delete(:auth_return_url) || request.env['omniauth.origin'] || stored_location_for(resource) || signed_in_root_path(resource)
  end
end
