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

  def set_session_key
    session[:response_key] ||= {}
    if params[:response_key]
      @run = Run.find_or_create_by_key_and_activity_id(params[:response_key], @activity.id)
      @session_key = @run.key
    elsif session[:response_key][@activity.id]
      @run = Run.find_or_create_by_key_and_activity_id(session[:response_key][@activity.id], @activity.id)
      @session_key = @run.key
    elsif current_user
      @run = Run.find_or_create_by_activity_id_and_user_id(@activity.id, current_user.id)
      @session_key = @run.key
    else
      @run = Run.create(:activity => @activity)
      @session_key = @run.key
    end
    session[:response_key][@activity.id] = @session_key
    # TODO: clear this hash on logout for logged-in users - requires finding callback in Devise
  end
end
