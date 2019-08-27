class Api::V1::JwtController < ApplicationController
  layout false

  skip_before_filter :verify_authenticity_token, :only => [:get_firebase_jwt]

  def get_firebase_jwt
    if params[:run_id]
      run = Run.find_by_id(params[:run_id])
      return error(404, "Run not found: #{params[:run_id]}") unless run
      return error(500, "Run has no remote_endpoint") unless run.remote_endpoint && !run.remote_endpoint.empty?
      return error(500, "Anonymous runs cannot request a JWT") unless current_user
      return error(500, "You are not the owner of the run or an admin") unless (run.user_id == current_user.id) || current_user.is_admin
      remote_url = run.remote_endpoint
    elsif session[:portal_domain] && session[:portal_user_id]
      run = nil
      portal_for_url = Concord::AuthPortal.portal_for_url(session[:portal_domain])
      return error(500, "No portal found for portal_domain (#{session[:portal_domain]}) in session") unless portal_for_url
      remote_url = portal_for_url.url
    else
      return error(500, "Session has no portal_domain and portal_user_id")
    end

    begin
      auth_token = Concord::AuthPortal.auth_token_for_url(remote_url)
    rescue Exception => e
      return error(500, e.message)
    end

    body = params.except(:action, :controller, :run_id).dup()

    uri = URI.parse(remote_url)
    if run
      learner_id_or_key = uri.path.split("/").pop()
      body[:learner_id_or_key] = learner_id_or_key
    else
      body[:user_id] = session[:portal_user_id]
    end

    portal_url = "#{uri.scheme}://#{uri.host}:#{uri.port}/api/v1/jwt/firebase"
    response = HTTParty.post(portal_url, {
      body: body,
      headers: {
        "Authorization" => auth_token
      }
    })
    render :json => response.body, :status => response.code
  end

  private

  def error(status, message)
    render :json => {:response_type => "ERROR", :error => message}, :status => status
  end
end