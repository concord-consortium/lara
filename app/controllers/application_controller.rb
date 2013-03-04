class ApplicationController < ActionController::Base
  # Run authorization on all actions
  # check_authorization

  # What to do if authorization fails
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_url, :alert => exception.message
  end

  # For modal edit windows. Source: https://gist.github.com/1456815
  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }
end
