class ApplicationController < ActionController::Base
  # Run authorization on all actions
  # check_authorization
  protect_from_forgery

  # What to do if authorization fails
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to user_omniauth_authorize_path(:concord_portal), :alert => exception.message
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

  def save_portal_info
    session[:portal] = RemotePortal.new(params)
  end

  def update_portal_session
    if params[:domain] && params[:externalId]
      save_portal_info
      session[:auth_return_url] = request.url
      unless session[:did_reauthenticate]
        session[:did_reauthenticate] = true
        sign_out(current_user)
        redirect_to user_omniauth_authorize_path(:concord_portal)
      end
    end
  end

  def clear_session_response_key
    session.delete(:response_key)
  end

  def session_response_key(new_val=nil?)
    return nil unless current_user.nil?
    session[:response_key] ||= {}
    # If there is a response key in the session which doesn't match up to a
    # current run, return nil (as though there's no session key)
    if Run.for_key(session[:response_key][@activity.id], @activity).nil?
      return nil
    end
    session[:response_key][@activity.id] = new_val if new_val
    session[:response_key][@activity.id]
  end

  def set_response_key(key)
    @session_key = key
    session_response_key(@session_key)
    params[:response_key] =   key
  end

  def update_response_key
    set_response_key(params[:response_key] || session_response_key)
  end

  def set_run_key
    update_response_key
    portal = RemotePortal.new({})
    if session.delete(:did_reauthenticate)
      portal = session.delete(:portal)
    else
      update_portal_session
    end
    @run = Run.lookup(@session_key, @activity, current_user, portal)
    set_response_key(@run.key)
  end


  # override devise's built in method so we can go back to the path
  # from which authentication was initiated
  def after_sign_in_path_for(resource)
    clear_session_response_key
    session.delete(:auth_return_url) || request.env['omniauth.origin'] || stored_location_for(resource) || signed_in_root_path(resource)
  end


end
