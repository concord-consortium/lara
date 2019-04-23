# Used to compare old browsers using useragent gem.
# see reject_old_browsers method
BrowserSpecificiation = Struct.new(:browser, :version)

class ApplicationController < ActionController::Base

  # Run authorization on all actions
  # check_authorization
  protect_from_forgery

  # What to do if authorization fails
  rescue_from CanCan::AccessDenied do |exception|
    response_data = unauthorized_response_data(exception.action, exception.subject)
    respond_to do |format|
      format.html { render :partial => "shared/unauthorized", :locals => {:message => response_data[:message]}, :status => 403 }
      format.json { render json: response_data, status: 403}
    end
  end

  # With +respond_to do |format|+, "406 Not Acceptable" is sent on invalid format.
  # With a regular render (implicit or explicit), ActionView::MissingTemplate
  # exception is raised instead. If we then raise a RoutingError Rails turns it
  # into a 404 response.
  rescue_from(ActionView::MissingTemplate) do |e|
    request.format = :html
    raise ActionController::RoutingError.new('Not Found')
  end

  before_filter :log_session_before
  before_filter :portal_login
  before_filter :reject_old_browsers, :except => [:bad_browser]
  before_filter :set_locale
  before_filter :store_auto_publish_url # to enable auto publishing to build an url from the request object
  after_filter :log_session_after

  # Try to set local from the request headers
  def set_locale
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = extract_locale_from_accept_language_header
    logger.debug "* Locale set to '#{I18n.locale}'"
  end
  private
  def extract_locale_from_accept_language_header
    lang_header = request.env['HTTP_ACCEPT_LANGUAGE']
    return "en" unless lang_header
    return lang_header.scan(/^[a-z]{2}/).first
  end
  public


  ### Log some data for 404s
  # This should be temporary, as debugging for an issue where links to an activity return 404 errors for
  # some people but not others.
  # See https://www.pivotaltracker.com/story/show/52313089
  # Turned off 21Oct2013 - pjm
  # rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  #
  # def not_found(exception)
  #   ExceptionNotifier.notify_exception(exception,
  #     :env => request.env, :data => {:message => "raised a Not Found exception"})
  #   redirect_to root_url, :alert => exception.message
  # end

  # For modal edit windows. Source: https://gist.github.com/1456815
  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }

  def update_activity_changed_by(activity=@activity)
    activity.changed_by = current_user
    begin
      activity.save
    rescue
      # We don't want to return a server error if this update fails; it's not important
      # enough to derail the user.
      logger.debug "changed_by update for Activity #{@activity.id} failed."
    end
  end

  def current_theme
    # Assigns @theme
    # This counts on @activity and/or @sequence being already assigned.
    if defined?(@sequence) && @sequence.theme
      @theme = @sequence.theme
    elsif defined?(@activity) && @activity.theme
      @theme = @activity.theme
    elsif defined?(@project) && @project.theme
      @theme = @project.theme
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
    # First, respect the sequence ID in the request params if one is provided
    if params[:sequence_id]
      @sequence = Sequence.find(params[:sequence_id])
      # Save this in the run
      if @sequence && @run
        @run.sequence = @sequence
        @run.save
      end
    # Second, if there's no sequence ID in the request params, there's an existing
    # run, and a sequence is set for that run, use that sequence
    elsif @run && @run.sequence
      @sequence ||= @run.sequence
    end
    @sequence
  end

  protected

  # this is used by controllers that look up a Run based on a run_key
  # if the current_user is not authorized to access the run then this method
  # is called
  def user_id_mismatch
    @hide_navigation = true
    @user = current_user ? current_user.email : 'anonymous'
    @run_key = params[:run_key] || 'no run key'
    @session = session.clone
    session.delete("run_key")

    NewRelic::Agent.notice_error(RuntimeError.new("_run_user_id_mismatch"), {
      uri: request.original_url,
      referer: request.referer,
      request_params: params,
      custom_params: { user: @user, run_key: @run_key }.merge(@session)
    })
  end

  def clear_session_run_key
    session.delete(:run_key)
  end

  def session_run_key(new_val=nil?)
    return nil unless current_user.nil?
    session[:run_key] ||= {}
    # If there is a run key in the session which doesn't match up to a
    # current run, return nil (as though there's no run key)
    if Run.for_key(session[:run_key][@activity.id], @activity).nil?
      return nil
    end
    session[:run_key][@activity.id] = new_val if new_val
    session[:run_key][@activity.id]
  end

  def set_run_key_REFACTOR(key)
    @run_key = key
    session_run_key(@run_key)
  end

  def update_run_key
    set_run_key_REFACTOR(params[:run_key] || session_run_key)
  end

  def set_run_key
    update_run_key

    # Special case when collaborators_data_url is provided (usually as a GET param).
    # New collaboration will be created and setup and call finally returns collaboration owner
    if params[:collaborators_data_url]
      cc = CreateCollaboration.new(params[:collaborators_data_url], current_user, @activity)
      @run = cc.call
    else
      portal = RemotePortal.new(params)
      # This creates a new key if one didn't exist before
      @run = Run.lookup(@run_key, @activity, current_user, portal, params[:sequence_id])
      # If activity is ran with "portal" params, it means that user wants to run it individually.
      # Note that "portal" refers to individual student data endpoint, this name should be updated.
      if portal.valid?
        @run.disable_collaboration
      end
    end

    @sequence_run = @run.sequence_run if @run.sequence_run
    # This is redundant but necessary if the first pass through set_run_key_REFACTOR returned nil
    set_run_key_REFACTOR(@run.key)
  end

  # Exports logger configuration and data. Note that you have to explicitly specify 'enable_js_logger' as before_filter
  # for every action which should have logging enabled.
  def enable_js_logger
    unless params[:logging].nil?
      # Update session when logging param is provided (usually as GET param).
      session[:logging] = params[:logging] == "true"
    end

    unless session[:logging]
      gon.loggerConfig = nil
      return
    end

    data = {
        application: ENV['LOGGER_APPLICATION_NAME'],
        session:     session[:session_id],
        username:    current_user ? "#{session[:portal_user_id]}@#{session[:portal_domain]}" : 'anonymous',
        url:         request.original_url
    }
    if @run
      data[:run_key] = @run.key
      data[:run_remote_id] = @run.remote_id
      data[:run_remote_endpoint] = @run.remote_endpoint
    end
    if @sequence
      # Activity field is a bit confusing name, but let's assume that it indicates which activity *or* sequence has
      # been started by user.
      data[:activity]      = "sequence: #{@sequence.id}"
      data[:sequence_id]   = @sequence.id
      data[:sequence_name] = @sequence.name
    end
    if @activity
      # Set activity name only if it hasn't been already set. Note that when both @activity and @sequence are available,
      # "sequence: <ID>" will be used (as user has started sequence and activity is only part of it).
      data[:activity]    ||= "activity: #{@activity.id}"
      data[:activity_id]   = @activity.id
      data[:activity_name] = @activity.name
    end
    if @page
      data[:page_id] = @page.id
    end

    # Export to gon namespace, available in JavaScript under window.gon (see: https://github.com/gazay/gon).
    gon.loggerConfig = {
      server: ENV['LOGGER_URI'],
      action: "#{controller_name}##{action_name}",
      data:   data
    }
  end

  # login to the portal provided in the parameters
  def portal_login
    if params[:domain]
      sign_out(current_user) unless has_matching_domain_uid(params[:domain],params[:domain_uid])
      # Remove domain from original url to avoid infinite loop.
      uri = URI(request.original_url)
      query_params = request.query_parameters
      query_params.delete(:domain)
      query_params.delete(:domain_uid)
      uri.query = URI.encode_www_form(query_params)
      # we set the origin here which will become request.env['omniauth.origin']
      # in the callback phase, by default omniauth will use use
      # the referer and that is not changed during redirects. More info:
      # https://github.com/intridea/omniauth/wiki/Saving-User-Location
      strategy_name = Concord::AuthPortal.strategy_name_for_url(params[:domain])
      redirect_to user_omniauth_authorize_path(strategy_name, :origin => uri.to_s)
    end
  end

  # check if any of them have a matching domain and uid
  def has_matching_domain_uid(domain,domain_uid)
    return current_user && current_user.authentications.where(provider:Concord::AuthPortal.strategy_name_for_url(params[:domain]),uid:domain_uid).length > 0
  end

  # override devise's built in method so we can go back to the path
  # from which authentication was initiated
  def after_sign_in_path_for(resource)
    clear_session_run_key
    request.env['omniauth.origin'] || stored_location_for(resource) || signed_in_root_path(resource)
  end


  def after_sign_out_path_for(resource)
    if params[:user_provider]
      provider = params[:user_provider]
      provider_id = provider.clone
      "#{Concord::AuthPortal.url_for_strategy_name(provider_id)}users/sign_out"
    else
      root_path
    end
  end

  def respond_with_edit_form
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit')}, :content_type => 'text/json' }
      format.html
    end
  end

  def respond_with_nothing
    # This is useful for AJAX actions, because it returns a 200 status code but doesn't bother generating an actual response.
    respond_to do |format|
      format.js { render :nothing => true }
      format.html { render :nothing => true }
    end
  end

  def simple_update(subject)
    respond_to do |format|
      if subject.update_attributes(params[subject.class.to_s.downcase.to_sym]) # Surely there's a simpler way?
        format.html { redirect_to edit_polymorphic_url(subject), notice: "#{subject.class.to_s} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: subject.errors, status: :unprocessable_entity }
      end
    end
  end

  def reject_old_browsers
    user_agent = UserAgent.parse(request.user_agent)
    min_browser = BrowserSpecificiation.new("Internet Explorer", "9.0")
    if user_agent < min_browser
      @wide_content_layout = true
      @user_agent = user_agent
      redirect_to '/home/bad_browser'
    end
  end

  def setup_global_interactive_state_data
    gon.globalInteractiveState = {
      save_url: run_global_interactive_state_path(@run)
    }
    if @run.global_interactive_state
      gon.globalInteractiveState[:raw_data] = @run.global_interactive_state.raw_data
    end
  end

  def log_session_before
    logger.info("session before:" + session.inspect)
  end

  def log_session_after
    logger.info("session after:" + session.inspect)
  end

  def handle_unverified_request
    logger.info("unverified_request session:" + session.inspect)
    reset_session
  end

  def store_auto_publish_url
    Thread.current[:auto_publish_url] = "#{request.protocol}#{request.host_with_port}"
  end

  def unauthorized_response_data(action, resource)
    if current_user
      user = session[:portal_username] || current_user.email
    else
      user = "Anonymous"
    end

    className = resource && resource.class.name
    if className == "LightweightActivity" || className == "Sequence"
      message = "#{user}, you don't have permission to #{action} the #{className} with id : #{resource.id}"
    else
      message = "#{user}, you don't have permission to access this page."
    end

    {
      :user => user,
      :className => className,
      :id => resource && resource.respond_to?(:id) ? resource.id : 'n/a',
      :message => message
    }
  end
end
