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

  def get_response_key
    session[:response_key] ||= {}
    if params[:response_key]
      session[:response_key][@activity.id] = params[:response_key]
    end
    session[:response_key][@activity.id]
  end

  def external_id
    if params[:domain] && params[:externalId]
      key = "#{params[:domain]}#{params[:externalId]}"
      return key.gsub(/[^a-zA-Z0-9 -]/,"")
    end
    return nil
  end

  def set_session_key
    response_key = get_response_key
    @run = Run.lookup(response_key,@activity,current_user, external_id)
    if params[:returnUrl]
      @run.remote_endpoint = params[:returnUrl]
      @run.save
    end
    @session_key = session[:response_key][@activity.id] = @run.key
    # TODO: clear this hash on logout for logged-in users - requires finding callback in Devise
  end

  # override devise's built in method so we can go back to the path
  # from which authentication was initiated
  def after_sign_in_path_for(resource)
    session.delete(:auth_return_url) || request.env['omniauth.origin'] || stored_location_for(resource) || signed_in_root_path(resource)
  end
end
