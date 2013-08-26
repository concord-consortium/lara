class SequenceRun < ActiveRecord::Base
  attr_accessible :remote_endpoint, :remote_id, :user_id, :sequence_id

  has_many :runs
  belongs_to :sequence
  belongs_to :user

  def self.lookup_or_create(sequence, user, portal)

    conditions = {
      remote_endpoint: portal.remote_endpoint,
      remote_id:       portal.remote_id,
      user_id:         user.id,
      sequence_id:     sequence.id
      #TODO: add domain
    }
    found = self.find(:first, :conditions => conditions)
    found ||= self.create(conditions)
    found.make_or_update_runs
    found
  end

  def run_for_activity(activity)
    runs.find {|run| run.activity_id == activity.id}
  end

  def make_or_update_runs
    sequence.activities.each do |activity|
      unless run_for_activity(activity)
        runs.create!({
          remote_endpoint: remote_endpoint,
          remote_id:       remote_id,
          user_id:         user.id,
          activity_id:     activity.id,
          sequence_id:     sequence.id
          })
      end
    end
  end
end
