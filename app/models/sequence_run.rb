class SequenceRun < ApplicationRecord

  has_many :runs
  belongs_to :sequence
  belongs_to :user

  before_save :add_key_if_nil

  # /app/models/with_class_info.rb for #update_platform_info
  include WithPlatformInfo

  def self.generate_key
    SecureRandom.hex(20)
  end

  def self.lookup_or_create(sequence, user, portal)
    if portal.valid? && user.nil?
      raise ActiveRecord::RecordNotFound.new(
        "user must be logged in to access a SequenceRun via portal parameters"
      )
    end

    conditions = {
      remote_endpoint: portal.remote_endpoint,
      remote_id:       portal.remote_id,
      user_id:         user ? user.id : nil,
      sequence_id:     sequence.id
      #TODO: add domain
    }
    seq_run = nil

    # we only look for an existing sequence run if there is a user
    # there will be multipe runs that match without a user and we won't know which one
    # so without a user we always create one
    if user
      seq_run = self.where(conditions).first
    end

    if seq_run.nil?
      seq_run = self.create!(conditions)
    end

    seq_run.update_platform_info(portal.platform_info)
    seq_run.make_or_update_runs
    seq_run
  end

  def run_for_activity(activity)
    run = runs.find {|run| run.activity_id == activity.id}
    if run.nil?
      if !sequence.lightweight_activities.exists?(activity.id)
        # probably need a better exception here, technically it would be possible for an
        # author to remove a activity just as the student loads the page so they might
        # request an activity that is no longer part of the sequence
        raise Exception.new("Activity is not part of this sequence")
      end
      # create the run, we use this form instead of runs.create to make testing
      # easier
      run = Run.create!({
        remote_endpoint: remote_endpoint,
        remote_id:       remote_id,
        user_id:         user ? user.id : nil,
        activity_id:     activity.id,
        sequence_id:     sequence.id,
      })
      # Copy platform info to newly created activity run.
      run.update_platform_info(self.attributes)
      runs << run
    end
    run
  end

  def to_param
    key
  end

  def most_recent_run
    runs.order('updated_at desc').first
  end

  def most_recent_activity
    most_recent_run.activity
  end

  def has_been_run
    a_position =  runs.detect { |r| r.has_been_run }
    return a_position.nil? ? false : true
  end

  def disable_collaboration
    # In theory we could keep reference to collaboration run in sequence.
    # However this approach seems to be more bulletproof, as it will definitely clear any possible
    # collaboration (it's not likely, but it may happen that there are a few different collaborations
    # related to different runs, not just single one).
    runs.select { |r| r.collaboration_run }.each { |r| r.collaboration_run.disable }
  end

  def make_or_update_runs
    sequence.activities.each do |activity|
      run_for_activity(activity)
    end
  end

  def completed?
    runs.count == sequence.activities.count && runs.all? { |r| r.completed? }
  end

  def add_key_if_nil
    self.key = SequenceRun.generate_key if self.key.nil?
  end
end
