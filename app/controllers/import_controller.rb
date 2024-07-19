class ImportController < ApplicationController

  include PeerAccess

  skip_before_filter :verify_authenticity_token, :only => :import

  def import_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('import')}, :content_type => 'text/json' }
      format.html
    end
  end

  def import
    import_result = Import.import("#{params[:import][:import].read}", current_user, params[:imported_activity_url])
    respond_to do |format|
      if import_result[:success]
        path = import_result[:type] === "Sequence" ? edit_sequence_path(import_result[:import_item]) :
               import_result[:type] === "Glossary" ? edit_glossary_path(import_result[:import_item]) :
               import_result[:type] === "Rubric" ? edit_rubric_path(import_result[:import_item]) :
                                                     edit_activity_path(import_result[:import_item])
        format.js { render :js => "window.location.href = '#{path}';" }
      else
        flash[:warning] = import_result[:error]
        format.js { render :json => { :error => import_result[:error] }, :status => 500 }
      end
    end
  end

  def import_portal_activity
    authorize_peer!

    request_json = JSON.parse "#{request.body.read}", :symbolize_names => true

    unless User.find_by_email request_json[:activity][:user_email]
      user = User.create(
        email: request_json[:activity][:user_email],
        password: User.get_random_password,
        is_author: true
      )
    end

    portal = Concord::AuthPortal.portal_for_url(request_json[:portal_url])
    authentication = Authentication.find_by_provider_and_uid(portal.strategy_name,request_json[:domain_uid])
    if authentication
      user = User.find(authentication.user_id)

      import_activity = LightweightActivity.import(request_json[:activity],user,request_json[:imported_activity_url])

      req_url = "#{request.protocol}#{request.host_with_port}"
      response_add_to_portal = import_activity.portal_publish(user,portal,req_url)
      response_code = response_add_to_portal.code
      if response_code == 201
        response_publish = import_activity.republish_for_portal(portal,req_url)
        response_code = response_publish.code
      else
        import_activity.destroy
        response.headers["data"] = {:response_code => response_code}.to_json
        render :nothing => true and return
      end

      response_body = JSON.parse "#{response_publish.body}", :symbolize_names => true
      response.headers["data"] = {:external_activity_id => response_body[:activity_id],
                                  :response_code => response_code}.to_json
    else
      response.headers["data"] = {:response_code => 401}.to_json
    end
    render :nothing => true
  end
end
