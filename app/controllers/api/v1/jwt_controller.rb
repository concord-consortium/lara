class Api::V1::JwtController < ApplicationController
  layout false

  skip_before_filter :verify_authenticity_token, :only => [:get_firebase_jwt]

  def get_firebase_jwt
    run = Run.find_by_id(params[:run_id])
    return error(404, "Run not found: #{params[:run_id]}") unless run
    return error(500, "Run has no remote_endpoint") unless run.remote_endpoint && !run.remote_endpoint.empty?
    return error(500, "Anonymous runs cannot request a JWT") unless current_user
    return error(500, "You are not the owner of the run or an admin") unless (run.user_id == current_user.id) || current_user.is_admin

    begin
      auth_token = Concord::AuthPortal.auth_token_for_url(run.remote_endpoint)
    rescue Exception => e
      return error(500, e.message)
    end

    uri = URI.parse(run.remote_endpoint)
    learner_id_or_key = uri.path.split("/").pop()
    portal_url = "#{uri.scheme}://#{uri.host}:#{uri.port}/api/v1/jwt/firebase"

    body = params.except(:action, :controller, :run_id).dup()
    body[:learner_id_or_key] = learner_id_or_key

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