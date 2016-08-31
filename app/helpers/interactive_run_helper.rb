module InteractiveRunHelper


  def save_interactive_button_tag(interactive,run)
    opts = {
      'data-interactive-id' => interactive.id,
      'id' =>"save_interactive",
      'data-put-url'  => put_url(interactive,run)
    }
    button_tag "save",  opts
  end

  def revert_interactive_button_tag(interactive,run)
    opts = {
      'data-interactive-id' => interactive.id,
      'id' =>"revert_interactive",
      'data-get-url'  => get_url(interactive,run)
    }
    button_tag "revert",  opts
  end

  def get_url(interactive,run)
    interactive_run = InteractiveRunState.by_run_and_interactive(run,interactive)
    api_v1_show_interactive_run_state_path(:key => interactive_run.key)
  end

  def put_url(interactive,run)
    interactive_run = InteractiveRunState.by_run_and_interactive(run,interactive)
    api_v1_update_interactive_run_state_path(:key => interactive_run.key)
  end

  def interactive_data_div(interactive,run)
    data = {}
    if (run)
      data['puturl'] = put_url(interactive,run)
      data['geturl'] = get_url(interactive,run)
      data['loggedin'] = (!!run.user).to_s
      data['authprovider'] = (Concord::AuthPortal.url_for_strategy_name(run.user.most_recent_authentication.provider) rescue nil) if data['loggedin'] == "true"
      data['user-email'] = run.user.email if data['loggedin'] == "true"
    end

    opts = {
      :src => interactive.url,
      :data => data,
      :class => 'interactive_data_div'
    }
    capture_haml do
      haml_tag 'span', opts
    end
  end

  def interactive_iframe_tag(interactive,run=nil,iframe_src=true)
    url = nil
    if run
      interactive_run = InteractiveRunState.by_run_and_interactive(run,interactive)
      url = interactive_run.learner_url
    end
    url = interactive.url if url.blank?

    data = {
      :aspect_ratio => interactive.aspect_ratio,
      :id => interactive.id,
      :iframe_mouseover => "false"
    }

    opts = {
      :width => "100%",
      :frameborder => "no",
      :scrolling => "no",
      :allowfullscreen => "true",
      :webkitallowfullscreen => "true",
      :mozallowfullscreen => "true",
      :src => iframe_src ? url : nil,
      :data => data,
      # Note that iframe is hidden in print mode. It won't have enough time to load anyway.
      :class => 'interactive screen-only',
      :id => "interactive_#{interactive.id}"
    }
    capture_haml do
      haml_tag 'iframe', opts
    end
  end

end
