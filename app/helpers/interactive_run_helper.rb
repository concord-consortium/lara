module InteractiveRunHelper


  def save_interactive_button_tag(interactive,run)
    opts = {
      'data-interactive-id' => interactive.id,
      'id' =>"save_interactive",
      'data-interactive-run-state-url' => interactive_run_state_url(interactive,run)
    }
    button_tag "save",  opts
  end

  def revert_interactive_button_tag(interactive,run)
    opts = {
      'data-interactive-id' => interactive.id,
      'id' =>"revert_interactive",
      'data-interactive-run-state-url' => interactive_run_state_url(interactive,run)
    }
    button_tag "revert",  opts
  end

  def interactive_run_state_url(interactive,run)
    interactive_run = InteractiveRunState.by_run_and_interactive(run,interactive)
    api_v1_show_interactive_run_state_url(:key => interactive_run.key)
  end

  def interactive_data_div(interactive,run)
    data = {}
    if (run)
      data['interactive-run-state-url'] = interactive_run_state_url(interactive,run)
      if run.collaboration_run
        collaborator_urls = []
        run.collaboration_run.collaborators_runs(run.activity, run.user).each do |collaborator_run|
          collaborator_urls.push(interactive_run_state_url(interactive,collaborator_run))
        end
        data['collaborator-urls'] = collaborator_urls.join(';')
      end
      data['loggedin'] = (!!run.user).to_s
      data['authprovider'] = (Concord::AuthPortal.url_for_strategy_name(run.user.most_recent_authentication.provider) rescue nil) if data['loggedin'] == "true"
      data['user-email'] = run.user.email if data['loggedin'] == "true"
      data['class-info-url'] = run.class_info_url
      if run.id
        data['get-firebase-jwt-url'] = api_v1_get_firebase_jwt_url(run.id)
      end
    end
    data['enable-learner-state'] = interactive.enable_learner_state.to_s
    data['authored-state'] = interactive.authored_state
    data['interactive-id'] = interactive.id
    data['interactive-name'] = interactive.name
    data['get-interactive-list-url'] = api_v1_get_interactive_list_url(interactive.interactive_page.id)

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

      # create interactive run states for collaborators so the docstore v2 api can set the doc id and access keys
      if run.collaboration_run
        run.collaboration_run.collaborators_runs(run.activity, run.user).each do |collaborator_run|
          InteractiveRunState.by_run_and_interactive(collaborator_run, interactive)
        end
      end
    end
    url = interactive.url if url.blank?

    data = {
      :aspect_ratio => interactive.aspect_ratio,
      :aspect_ratio_method => interactive.aspect_ratio_method,
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
      :allow => "geolocation *; microphone *; camera *",
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
