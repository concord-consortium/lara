class RunsController < ApplicationController
  layout false, :except => [:dirty]
  before_filter :set_run, :except => [:index, :fix_broken_portal_runs]

  def index
    # This is actually a special case of show - create an Run and show it
    # - so we'll do that work here and redirect there
    @activity = LightweightActivity.find(params[:activity_id])
    @run = Run.create(:activity => @activity, :user => current_user)
    redirect_to activity_run_url(@activity, @run)
  end

  def show
    render :json => @run.to_json(:methods => [:last_page, :storage_keys, :responses])
  end

  # we dont bulk-update a run currently. We might want to later.
  # https://gist.github.com/knowuh/590e61ce6ea4d3d3f2eb
  # If this run isn't owned by a registered user, and is updated by one, that user now owns it
  # def update
  # end

  def dirty
    @runs = Run.where('is_dirty = ?', true).where('updated_at < ?', 5.minutes.ago).order(:updated_at)
    respond_to do |format|
      format.html do
        authorize! :manage, :all # admins
      end
      format.json { render :json => { :dirty_runs => @runs.length }.to_json }
    end
  end

  def fix_broken_portal_runs
    message  = "must be admin."
    if current_user.is_admin
      run = Run.find(params[:run_id])
      token = false
      if params[:use_admin_token]
        results = run.submit_answers_now(current_user.authentication_token)
      else 
        results = run.submit_answers_now
      end
      if results
        message = "Run answers resent to server (OK)"
      else
        message = "Run answers failted to send to server (BAD)"
      end
    end
    render json: { message: message}.to_json
  end


  def run_info
    message  = "must be admin."
    if current_user.is_admin
      run = Run.find(params[:run_id])
      message = run.info
      message << "---------------\n"
      message << remote_info(run)
    end
    render json: { message: message}.to_json
  end



  private
  def set_run
    @run = Run.find_or_create_by_key_and_activity_id(params[:id], params[:activity_id])
  end

  def remote_info(run)
    return "no remote details available" if run.remote_endpoint.blank?
    begin
      src = "/dataservice/external_activity_data/"
      dst = "/admin/learner_detail/"
      info_url = run.remote_endpoint.gsub(src,dst) << ".txt"
      token = 'Bearer %s' % current_user.authentication_token
      response = HTTParty.get(info_url,
        :headers => {"Authorization" => token, "Content-Type" => 'text/plain'})
    rescue
      return ""
    end
    return response
  end
end
