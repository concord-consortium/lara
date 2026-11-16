module RedirectWriteCounts
  def written_rows
    [SequenceRun.count, Run.count, CollaborationRun.count, User.count]
  end
end

RSpec.configure do |config|
  config.include RedirectWriteCounts, type: :controller
end
