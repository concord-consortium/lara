module LightweightActivityHelper
  def toggle_all(label='all', id_prefix='details_')
    link_to_function("show/hide #{label}", "$('div[id^=#{id_prefix}]').toggle();")
  end

  def has_good_content(value)
    return false if value.nil?
    related = value.gsub(/(<([^>]+)>)/,'')
    return (!related.blank?)
  end

  # Try to find the most specific path for the passed in activity, and the current state
  # of the sequence_run, sequence, and run
  def runnable_activity_path(activity, opts ={})
    if @sequence && @sequence_run
      append_white_list_params sequence_activity_with_run_path(@sequence, activity, @sequence_run.run_for_activity(activity), opts)
    elsif @sequence
      append_white_list_params sequence_activity_path(@sequence, activity, opts)
    elsif @run && @run.activity == activity
      append_white_list_params activity_with_run_path(activity, @run, opts)
    else
      append_white_list_params activity_path(activity, opts)
    end
  end

  # Try to find the most specific path for the passed in activity, and the current state
  # of the sequence_run, sequence, and run
  def runnable_summary_path(activity)
    if @sequence && @sequence_run
      append_white_list_params sequence_summary_with_run_path(@sequence, activity, @sequence_run.run_for_activity(activity))
    elsif @run && @run.activity == activity
      append_white_list_params summary_with_run_path(activity, @run)
    else
      raise Exception.new("no run or sequence run available")
    end
  end

  def runnable_single_page_activity_path(activity, opts={})
    if @sequence
      append_white_list_params sequence_activity_single_page_with_run_path(@sequence, @activity, @run.key, opts)
    else
      append_white_list_params activity_single_page_with_run_path(@activity, @run.key, opts)
    end
  end

  def activity_name_for_menu
    results = t("ACTIVITY")
    if @sequence
      results << " #{@activity.position(@sequence)}"
    end
    return "#{results}: #{@activity.name}"
  end

  def complete_badge_for(activity)
    return unless @sequence_run
    run = @sequence_run.run_for_activity(activity)
    if run.completed?
      return ribbon(t("COMPLETED"),"my-ribbon")
    end
  end

  def activity_player_url(activity, mode="")
    activity_api_url = "#{api_v1_activity_url(activity.id)}.json"
    uri = URI.parse(ENV["ACTIVITY_PLAYER_URL"])
    query = Rack::Utils.parse_query(uri.query)
    query["activity"] = URI.escape(activity_api_url)
    query["preview"] = nil # adds 'preview' to query string as a valueless param
    query["mode"] = mode
    uri.query = Rack::Utils.build_query(query)
    return uri.to_s
  end

  def activity_player_page_url(activity, page, mode="")
    return  "#{activity_player_url(activity, mode)}&page=#{page.position}"
  end

  def activity_player_conversion_url(activity)
    if @sequence
      lara_resource = "#{api_v1_activity_url(@sequence.id)}.json"
      resource_name = @sequence.title
    else
      lara_resource = "#{api_v1_activity_url(activity.id)}.json"
      resource_name = activity.name
    end

    uri = URI.parse(ENV['CONVERSION_SCRIPT_URL'])
    query = Rack::Utils.parse_query(uri.query)
    query["lara_resource"] = lara_resource
    query["resource_name"] = resource_name
    uri.query = Rack::Utils.build_query(query)
    return uri.to_s
  end

  def activity_preview_options(activity, page=nil)
    if page
      activity_player_url = activity_player_page_url(activity, page)
      activity_player_te_url = activity_player_page_url(activity, page, "teacher-edition")
      lara_runtime_url = preview_activity_page_path(activity, page)
      lara_runtime_te_url = preview_activity_page_path(activity, page, mode: "teacher-edition")
    else
      activity_player_url = activity_player_url(activity)
      activity_player_te_url = activity_player_url(activity, "teacher-edition")
      lara_runtime_url = preview_activity_path(activity)
      lara_runtime_te_url = preview_activity_path(activity, mode: "teacher-edition")
    end
    {
      'Select a runtime option...' => '',
      'Activity Player' => activity_player_url,
      'Activity Player Teacher Edition' => activity_player_te_url,
      'LARA Runtime' => lara_runtime_url,
      'LARA Runtime Teacher Edition' => lara_runtime_te_url
    }
  end

  def runtime_url(activity)
    if activity.runtime == "Activity Player"
      view_activity_url = activity.activity_player_url(request.protocol, request.host_with_port, true)
    else
      view_activity_url = activity_path(activity)
    end
    return view_activity_url
  end
end
