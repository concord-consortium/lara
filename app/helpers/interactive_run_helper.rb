module InteractiveRunHelper


  def save_interactive_button_tag(interactive,run)
    interactive_run = InteractiveRunState.by_run_and_interactive(run,interactive)
    opts = {
      'data-interactive-id' => interactive.id,
      'id' =>"save_interactive",
      'data-post-back-url'  => interactive_run_state_path(interactive_run, :method => "PUT")
    }
    button_tag "save",  opts
  end

  def revert_interactive_button_tag(interactive,run)
    interactive_run = InteractiveRunState.by_run_and_interactive(run,interactive)
    opts = {
      'data-interactive-id' => interactive.id,
      'id' =>"revert_interactive",
      'data-post-back-url'  => interactive_run_state_path(interactive_run)
    }
    button_tag "revert",  opts
  end

end
