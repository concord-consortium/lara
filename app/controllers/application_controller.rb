class ApplicationController < ActionController::Base
  # Run authorization on all actions
  # check_authorization
  protect_from_forgery

  # What to do if authorization fails
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to user_omniauth_authorize_path(:concord_portal), :alert => exception.message
  end

  ### Log some data for 404s
  # This should be temporary, as debugging for an issue where links to an activity return 404 errors for
  # some people but not others.
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    
  def not_found(exception)
    ExceptionNotifier::Notifier.exception_notification(request.env, exception,
      :data => {:message => "raised a Not Found exception"}).deliver
    redirect_to root_url, :alert => exception.message
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

  def current_theme
    # Assigns @theme
    # This counts on @activity and/or @sequence being already assigned.
    if defined?(@sequence) && @sequence.theme
      @theme = @sequence.theme
    elsif defined?(@activity) && @activity.theme
      @theme = @activity.theme
    # elsif project setting
    else
      @theme = Theme.default
    end
    @theme
  end

  def current_project
    # Assigns @project
    # This counts on @activity and/or @sequence being already assigned.
    if defined?(@sequence) && @sequence.project
      # Sequence project overrides activity and default
      @project = @sequence.project
    elsif defined?(@activity) && @activity.project
      # Activity project overrides default
      @project = @activity.project
    else
      @project = Project.default
    end
    @project
  end

  def set_sequence
    if params[:sequence_id]
      @sequence = Sequence.find(params[:sequence_id])
    end
    if @sequence && @run
      @run.sequence = @sequence
    elsif @run && @run.sequence
      @sequence ||= @run.sequence
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
    @run = Run.lookup(@session_key, @activity, current_user, portal) # This creates a new key if one didn't exist before
    set_response_key(@run.key) # This is redundant but necessary if the first pass through set_response_key returned nil
  end

  # override devise's built in method so we can go back to the path
  # from which authentication was initiated
  def after_sign_in_path_for(resource)
    clear_session_response_key
    session.delete(:auth_return_url) || request.env['omniauth.origin'] || stored_location_for(resource) || signed_in_root_path(resource)
  end

end
