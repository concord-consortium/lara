module SequenceHelper
  def activity_player_sequence_url(sequence)
    sequence_api_url = "#{api_v1_sequence_url(@sequence.id)}.json"
    return  "#{ENV['ACTIVITY_PLAYER_URL']}/?sequence=#{CGI.escape(sequence_api_url)}&preview"
  end
end