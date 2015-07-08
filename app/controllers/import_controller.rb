class ImportController < ApplicationController

  include PeerAccess

  skip_before_filter :verify_authenticity_token, if: :verified_json_request?

  def verified_json_request?
    verify_request_is_peer
  end

  def import_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('import')}, :content_type => 'text/json' }
      format.html
    end
  end
  
  def import
    @import_item = Import.import(params[:import],current_user)
    res_name = @import_item.nil? ? '' : @import_item.class.name == 'LightweightActivity' ? 'activities' : 'sequences'  
    respond_to do |format|
      unless(res_name == '')
        unless @import_item.valid?
          flash[:warning] =  "<p>The import activity had validation issues:</p> #{@import_item.errors}"
        end
        if @import_item.save(:validations => false)
          format.js { render :js => "window.location.href = '#{res_name}/#{@import_item.id}/edit';" }
        else
          format.js { render :json => { :error =>"Import failed."}, :status => 500 }
        end
      else
        format.js { render :json => { :error =>"Import failed because of invalid JSON file."}, :status => 500 }
      end
    end
  end

  def import_portal_activity
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
    user = User.find(authentication.user_id)

    import_activity = LightweightActivity.import(request_json[:activity],user)

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
    render :nothing => true
  end
end