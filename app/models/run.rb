class Run < ApplicationRecord

  # NOTE: additional status flags should use bitmask values (0x2, 0x4, etc) so that multiple flags can be set at the same time
  SentToReportServiceStatusFlag = 0x1

  # Trigger whenever a portal update job needs to be re-run
  class PortalUpdateIncomplete < StandardError; end
  class InvalidJobState < StandardError; end


  belongs_to :activity, class_name: "LightweightActivity"

  belongs_to :user

  belongs_to :page, class_name: "InteractivePage" # last page

  belongs_to :sequence # optional

  belongs_to :sequence_run # optional

  belongs_to :collaboration_run # optional

  has_many :multiple_choice_answers,
    class_name: 'Embeddable::MultipleChoiceAnswer',
    foreign_key: 'run_id',
    dependent: :destroy

  has_many :open_response_answers,
    class_name: 'Embeddable::OpenResponseAnswer',
    foreign_key: 'run_id',
    dependent: :destroy

  has_many :image_question_answers,
    class_name: 'Embeddable::ImageQuestionAnswer',
    foreign_key: 'run_id',
    dependent: :destroy

  has_many :labbook_answers,
    class_name: 'Embeddable::LabbookAnswer',
    foreign_key: 'run_id',
    dependent: :destroy

  has_many :interactive_run_states

  has_one :global_interactive_state

  before_validation :check_key
  after_create :update_activity_portal_run_count

  scope :by_key, ->(k) { where(key: k) }

  validates :key,
    format: { with: /\A[a-zA-Z0-9\-]*\z/ },
    length: { is: 36 }

  # /app/models/with_class_info.rb for #update_platform_info
  include WithPlatformInfo

  def check_key
    unless key.present?
      self.key = session_guid
    end
  end

  # Generates a GUID for a particular run of an activity
  def session_guid
    UUIDTools::UUID.random_create.to_s
  end

  def self.for_user_and_portal(user,activity,portal)
    conditions = {
      remote_endpoint: portal.remote_endpoint,
      remote_id:       portal.remote_id,
      user_id:         user.id
      #TODO: add domain
    }
    conditions[:activity_id]     = activity.id if activity
    run = self.where(conditions).first
    unless run
      run = self.create!(conditions)
    end
    run.update_platform_info(portal.platform_info)
    run
  end

  def self.for_user_activity_and_sequence(user,activity,seq_id)
    # we limit this to only finding runs without portal properties, those lookups
    # should happen via for_user_and_portal
    conditions = {
      activity_id:     activity.id,
      user_id:         user ? user.id : nil,
      sequence_id:     seq_id,
      remote_endpoint: nil,
      remote_id:       nil
    }

    # we can only look for an existing run if the user is set
    # if the user is anonymous there will be many matching runs but we don't
    # know which one is the right one
    if (user)
      found = self.where(conditions).first
      if found
        return found
      end
    end

    # if no run has been found and there is a seq_id, create a sequence run too
    if seq_id
      seq_run = SequenceRun.lookup_or_create(Sequence.find(seq_id), user, RemotePortal.new({}))
      return seq_run.run_for_activity(activity)
    else
      return self.create!(conditions)
    end
  end

  def self.lookup(key, activity, user, portal, seq_id)
    if portal && portal.valid?
      if user
        # if the seq_id is set here, this is an un-handled state
        if seq_id
          # this should be be cut off before it even gets here see:
          # portal_launchable in lightweight_activities_controller
          raise Exception.new("portal launch of activity inside of a sequences")
        end
        return self.for_user_and_portal(user, activity, portal)
      else
        raise ActiveRecord::RecordNotFound.new(
          "user must be logged in to access a Run via portal parameters"
        )
      end
    end
    if key
      # error out if run can't be found
      run = self.where(key: key).first!

      if activity && run.activity_id != activity.id
        raise ActiveRecord::RecordNotFound.new(
          "Activity: #{activity.id} doesn't match run.activity_id: #{run.activity_id}")
      end

      if seq_id
        if run.sequence_id != seq_id.to_i
          raise ActiveRecord::RecordNotFound.new(
            "Sequence: #{seq_id} doesn't match run.sequence_id: #{run.sequence_id}"
          )
        end
        if run.sequence_run.nil?
          raise ActiveRecord::RecordNotFound.new(
            "run.sequence_run is nil looking up a run for Sequence: #{seq_id}"
          )
        end
      end

      return run
    end

    # it is an error condition if the activity is not set
    if (activity.nil?)
      raise ActiveRecord::RecordNotFound
    end

    return self.for_user_activity_and_sequence(user,activity,seq_id)
  end

  def self.auth_provider(remote_endpoint)
    uri = URI.parse(remote_endpoint)
    auth_url = (uri.port == 80) ? "#{uri.scheme}://#{uri.host}" : "#{uri.scheme}://#{uri.host}:#{uri.port}"
    ENV['CONFIGURED_PORTALS'].split.each do |cp|
      if ENV["CONCORD_#{cp}_URL"] == auth_url
        return cp
      end
      return nil
    end
  end

  def to_param
    key
  end

  def get_auth_provider
    self.remote_endpoint.blank? ? nil : Run.auth_provider(self.remote_endpoint)
  end

  def last_page
    return self.page
  end

  def set_last_page(page)
    update!(page_id: page.id)
    if collaboration_run && collaboration_run.is_owner?(user)
      collaboration_run.collaborators_runs(activity, user).each do |r|
        r.set_last_page(page)
      end
    end
  end

  def has_been_run
    return run_count && run_count > 0
  end

  def increment_run_count!
    self.run_count ||= 0
    increment!(:run_count)
  end


  def answers
    open_response_answers + multiple_choice_answers + image_question_answers + labbook_answers + interactive_run_states
  end

  def answers_hash
    answers.map {|a| a.portal_hash}
  end

  def clear_answers
    # It can be beneficial, particularly for authors, to come to a page/activity
    # with previous answers erased, so let's make it easy to clear them.
    answers.each { |a| a.destroy }
    if global_interactive_state
      global_interactive_state.destroy
    end
  end

  def all_responses_for_portal
    answers_hash.to_json
  end

  def disable_collaboration
    if collaboration_run
      collaboration_run.disable
    end
  end

  # TODO: Alias to all_responses_for_portal
  def responses
    {
      'multiple_choice_answers' => self.multiple_choice_answers,
      'open_response_answers' => self.open_response_answers,
      'image_question_answers' => self.image_question_answers,
      'external_links' => self.interactive_run_states
    }
  end

  # return true if we want to take this run out of the queue: either for success, or any
  # other case where retrying is pointless (e.g. nowhere to send the data, no data to send).
  def send_to_portal(answers, start_time = Time.now)
    return true if remote_endpoint.nil? || remote_endpoint.blank? # Drop it on the floor
    return true if answers.blank? # Pretend we sent it, nobody will notice
    is_success = PortalSender::Protocol.instance(remote_endpoint).post_answers(answers, remote_endpoint, start_time)
    Rails.logger.info("Run sent to portal, success:#{is_success}, " +
      "num_answers:#{answers.count}, #{run_info_string}")
    # TODO: better error detection?
    abort_job_and_requeue(run_info_string() ) unless is_success
    is_success
  end

  def queue_for_portal
    # Don't check remote_endpoint so we can allow anonymous runs to be enqueued and sent to the report service.
    # The submit_dirty_answers will enqueue a job that will eventually call #send_to_portal which will drop
    # it on the floor silently but will then continue and send the answer to the report service.
    return false if answers.empty?
    if dirty?
      # no-op: only queue one time
    else
      mark_dirty
      submit_dirty_answers
    end
  end

  def dirty_answers
    # Returns an array of answers which have a dirty bit set
    return answers.select{ |a| a.dirty? }
  end

  def abort_job_and_requeue(message="")
    # If a method throws an exception it will be rerun later.
    # The method will be retried up to 25 times with exp. falloff.
    raise PortalUpdateIncomplete.new(message)
  end

  def submit_answers_now
    if send_to_portal(self.answers)
      set_answers_clean(self.answers)
      self.reload
      if dirty_answers.empty?
        self.mark_clean
        return true
      end
    end
    return false
  end

  def submit_dirty_answers
    Delayed::Job.enqueue(SubmitDirtyAnswersJob.new(self.id, Time.now))
  end

  def set_answers_clean(answers=[])
    # Takes an array of answers and sets their is_dirty bits to clean
    answers.each do |answer|
      answer.mark_clean
    end
  end

  def dirty?
    is_dirty
  end

  def mark_dirty
    self.is_dirty = true
    self.save
    # TODO: enqueue
  end

  def mark_clean
    self.is_dirty = false
    self.save
  end

  def update_activity_portal_run_count
    return unless self.activity
    return if self.remote_endpoint.blank?
    self.activity.increment!(:portal_run_count)
  end

  def num_reportable_items
    return self.activity.reportable_items.size
  end

  def num_answered_reportable_items
    q_answers = self.answers.reject { |a| !a.answered? }
    reportable_items = self.activity.reportable_items

    # we only want to include answers that coorespond to a reportable item.
    # some answers might not coorespond. For example if a item is hidden after students have used
    # it, then there will still be an answer this hidden item.
    # But the hidden item won't be in the reportable_items list

    answered_items = q_answers.select do |a|
      question = a.question
      reportable_items.include?(question)
    end
    answered_items.size
  end

  def completed?
    return has_been_run && num_answered_reportable_items == num_reportable_items
  end

  def percent_complete
    return (num_answered_reportable_items / Float(num_reportable_items) ) * 100.0
  end

  # See PT https://www.pivotaltracker.com/story/show/59365552
  # And stories about run links (can't find it.)
  def remove_answers_to_wrong_activity
    [:multiple_choice_answers, :open_response_answers, :image_question_answers].each do |answer_type|
      answers = self.send answer_type
      answers.each do |answer|
        if answer.question && answer.question.activity
          activity_id = answer.question.activity.id
          unless activity_id == self.activity_id
            answer.delete
            puts "deleted an answer to question: #{answer.question.id}"
          end
        end
      end
    end
  end

  def info
    # begin
      info=<<-EOF
                        run_id: #{id}
                       run_key: #{key}
                         dirty: #{dirty?}
               remote_endpoint: #{remote_endpoint}
              percent_complete: #{percent_complete}
  number of answered questions: #{num_answered_reportable_items}
             number of answers: #{answers.size}
           number of questions: #{num_reportable_items}
                      activity: #{activity.name} [#{activity_id}]
                      sequence: #{sequence_id}
                 collaboration: #{collaboration_run_id}
                  sequence_run: #{sequence_run_id}
                    other_runs: #{sequence_run.runs.map { |r| r.id }.join(",") if sequence_run}
          other seq activities: #{sequence_run.runs.map { |r| r.activity_id }.join(",") if sequence_run}
      EOF
      info.gsub(/^\s+/,'')
    # rescue NameError => e
    # end
  end

  def run_info_string()
    "remote_endpoint:#{remote_endpoint}, run_id:#{id}, " +
    "run_key:#{key}, dirty:#{dirty?}, " +
    "activity:#{activity_id}, activity_name:\"#{activity ? activity.name : 'nil'}\", " +
    "sequence:#{sequence_id}"
  end

  def lara_to_portal_secret_auth
    return 'Bearer %s' % Concord::AuthPortal.auth_token_for_url(self.remote_endpoint)
  end

  def set_status_flag(flag)
    self.status = status | flag
    self.save
  end

  def clear_status_flag(flag)
    self.status = status & ~flag
    self.save
  end
end
