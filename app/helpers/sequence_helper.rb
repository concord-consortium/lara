module SequenceHelper
  def sequence_runtime_url(sequence)
    if sequence.runtime == "Activity Player"
      view_sequence_url = sequence.activity_player_sequence_url(request.protocol, request.host_with_port, true)
    else
      view_sequence_url = sequence_path(sequence)
    end
    return view_sequence_url
  end
end