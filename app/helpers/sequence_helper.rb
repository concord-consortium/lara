module SequenceHelper
  def sequence_preview_options(activity)
    base_url = request.base_url
    {
      'Select a runtime option...' => '',
      'Activity Player' => @sequence.activity_player_sequence_url(base_url, preview: true),
      'Activity Player Teacher Edition' => @sequence.activity_player_sequence_url(base_url, preview: true, mode: "teacher-edition")
    }
  end

  def sequence_runtime_url(sequence)
    if sequence.runtime == "Activity Player"
      view_sequence_url = sequence.activity_player_sequence_url(request.base_url, preview: true)
    else
      view_sequence_url = sequence_path(sequence)
    end
    return view_sequence_url
  end
end
