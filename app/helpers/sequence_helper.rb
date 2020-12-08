module SequenceHelper
  def activity_player_sequence_url(sequence, mode="")
    sequence_api_url = "#{api_v1_sequence_url(@sequence.id)}.json"
    return  "#{ENV['ACTIVITY_PLAYER_URL']}/?sequence=#{CGI.escape(sequence_api_url)}&preview&mode=#{mode}"
  end

  def sequence_preview_options(activity)
    {
      'Select a runtime option...' => '',
      'Activity Player' => activity_player_sequence_url(@sequence),
      'Activity Player Teacher Edition' => activity_player_sequence_url(@sequence, "teacher-edition")
    }
  end

  def sequence_runtime_url(sequence)
    if sequence.runtime == "Activity Player"
      view_sequence_url = sequence.activity_player_sequence_url(request.protocol, request.host_with_port, true)
    else
      view_sequence_url = sequence_path(sequence)
    end
    return view_sequence_url
  end
end