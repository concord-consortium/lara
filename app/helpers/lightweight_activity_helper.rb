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
end
