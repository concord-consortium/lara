module Embeddable::Answer
  def self.included base
    base.instance_eval do
      delegate :user,                     to: :run, allow_nil: true
      delegate :collaboration_run,        to: :run, allow_nil: true
      delegate :name,                     to: :question
      delegate :prompt,                   to: :question
      delegate :hint,                     to: :question
      delegate :default_text,             to: :question
      delegate :is_prediction,            to: :question
      delegate :give_prediction_feedback, to: :question
      delegate :prediction_feedback,      to: :question
      delegate :show_in_runtime?,         to: :question
      delegate :is_half_width,            to: :question

      def self.by_run(r)
        where(run_id: r.id)
      end
      def self.default_answer(conditions)
        self.create(conditions)
      end
    end
  end

  # DANGER TODO:  This memoization isn't going to work
  # the way the author intended, because that instance var is going
  # to be shared by every class that includes this module.
  @question_index = nil
  def question_index(skip_cache=false)
    # To skip the memoization and generate again, pass :true as an argument
    if skip_cache
      @question_index = nil
    end
    begin
      @question_index ||= self.question.index_in_activity(self.run.activity || self.question.activity)
    rescue StandardError => e
      logger.warn "Rescued #{e.class}: #{e.message}"
      return nil
    end
    @question_index
  end

  # Removes all content which is in italics from the prompt.
  # See https://www.pivotaltracker.com/story/show/50555355 for rationale.
  @cleaned_prompt = nil
  def prompt_no_itals(skip_cache=false)
    # To skip the memoization and generate again, pass :true as an argument
    if @cleaned_prompt.blank? || skip_cache
      parsed_prompt = Nokogiri::HTML::DocumentFragment.parse(prompt)
      itals = parsed_prompt.at_css "i"
      if itals
        itals.content = nil
      end
      @cleaned_prompt = parsed_prompt.to_html
    end
    return @cleaned_prompt
  end

  def send_to_portal
    if run
      mark_dirty
      run.queue_for_portal
    end
  end

  def propagate_to_collaborators
    # Propagate answer only when an owner of the collaboration updates his answer.
    # Otherwise we would end up with an infinite cycle.
    if collaboration_run && collaboration_run.is_owner?(user)
      collaboration_run.propagate_answer(self)
    end
  end

  # Overwrite these methods in class that includes this module:
  def copy_answer!(another_answer)
    raise "#copy_answer! unimplemented for a given type of answer"
  end

  def answered?
    raise "#answered? unimplemented for a given type of answer"
  end

  def to_json
    portal_hash.to_json
  end

  def dirty?
    is_dirty?
  end

  def mark_dirty
    # wont invoke callbacks
    update_column(:is_dirty, true)
  end

  def mark_clean
    # wont invoke callbacks
    update_column(:is_dirty, false)
  end

  # ID which is unique among all the answer types.
  def answer_id
    "#{self.class.to_s.demodulize.underscore}_#{self.id}"
  end
end
