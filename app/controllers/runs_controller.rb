class RunsController < ApplicationController
  layout false, :except => [:dirty, :details]
  before_filter :set_run, :except => [:index, :fix_broken_portal_runs, :dashboard]

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
      if run.submit_answers_now
        message = "Run answers resent to server (OK)"
      else
        message = "Run answers failted to send to server (BAD)"
      end
    end
    redirect_to  params.merge(message: message, action: 'dirty')
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

  def details
    authorize! :inspect, Run
    @runs     = []
    @students = []
    student_list = params['students'] ? params['students'].split(",") : []
    @student_learner_map = {}
    student_list.each do |li|
      learner_id,login = li.split(":")
      @student_learner_map[learner_id] = login
    end
    origin = params['origin']
    @report_info = origin
    if origin
      uri      = URI.parse(origin)
      path_rgx = "dataservice/external_activity_data"
      endpoint_base = "#{uri.scheme}://#{uri.host}"
      unless [443,80].include?(uri.port)
        endpoint_base << ":#{uri.port}"
      end
      endpoint_base  = "#{endpoint_base}/#{path_rgx}"
      learners       =  params['learners'].split(",")
      endpoints      = learners.map { |l| "#{endpoint_base}/#{l}" }
      @runs = Run.where(:remote_endpoint => endpoints).includes(:activity,:user)
      @students = @runs.map { |r| @student_learner_map[r.remote_id] }
      @runs = @runs.group_by { |r| r.sequence }
      render :layout => 'wide'
    else
      redirect_to url_for(params.merge(origin: request.referrer))
    end
  end

  # Used by Dashboard app.
  def dashboard
    page_id = params[:page_id]
    endpoint_urls = params[:endpoint_urls] || []
    submissions_created_after = params[:submissions_created_after]
    dashboard = DashboardRunlist.new(endpoint_urls, page_id, submissions_created_after)
    render json: dashboard.to_json, callback: params[:callback]
  end

  def unauthorized_feedback
    data = {
      username: params[:username],
      teacher: params[:teacher],
      description: params[:description],
      original_url: params[:original_url],
      session: session.clone,
      request: request
    }
    UnauthorizedFeedbackMailer.feedback(data).deliver
    render nothing: true, status: :created
  end

  private

  def set_run
    @run = Run.find_or_create_by(key: params[:id], activity_id: params[:activity_id])
  end

  def remote_info(run)
    authorize! :inspect, Run
    return "no remote details available" if run.remote_endpoint.blank?
    begin
      src = "/dataservice/external_activity_data/"
      dst = "/admin/learner_detail/"
      info_url = run.remote_endpoint.gsub(src,dst) << ".txt"
      response = HTTParty.get(info_url,
        :headers => {"Authorization" => run.lara_to_portal_secret_auth, "Content-Type" => 'text/plain'}, :timeout => 5)
    rescue
      return ""
    end
    return response
  end


end
