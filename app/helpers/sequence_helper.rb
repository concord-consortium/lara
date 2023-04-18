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
    sequence.activity_player_sequence_url(request.base_url, preview: true)
  end

  def activity_sequence_preview_url(activity)
    @sequence.activity_player_sequence_url(request.base_url, preview: true, activity: activity.id)
  end
end