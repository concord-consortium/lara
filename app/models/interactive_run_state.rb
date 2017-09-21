class InteractiveRunState < ActiveRecord::Base
  alias_method :original_json, :to_json  # make sure we can still generate json of the base model after including Answer
  include Embeddable::Answer # Common methods for Answer models

  attr_accessible :interactive_id, :interactive_type, :run_id, :raw_data, :interactive, :run, :key

  belongs_to :run
  belongs_to :interactive, :polymorphic => true

  after_update :maybe_send_to_portal

  before_save :add_key_if_nil

  def self.generate_key
    SecureRandom.hex(20)
  end

  def self.by_question(q)
    where(interactive_id: q.id, interactive_type: q.class.name)
  end

  def self.by_run_and_interactive(run,interactive)
    opts = {
      interactive_id: interactive.id,
      interactive_type: interactive.class.name,
      run_id: run.id
    }
    results = self.where(opts).first
    if results.nil?
      results = self.create(opts)
    end
    return results
  end

  # Make Embeddable::Answer assumptions work
  class QuestionStandin
    attr_accessor :interactive
    def name
      interactive.name.present? ? interactive.name : "Interactive"
    end
    def prompt; nil; end
    def is_prediction; false; end
    def give_prediction_feedback; false; end
    def prediction_feedback; nil; end
    def reportable?
      interactive.reportable?
    end
  end

  def question
    return @question if @question
    @question = QuestionStandin.new
    @question.interactive = interactive
    @question
  end

  def portal_hash
    # There are two options how interactive can be saved in Portal:
    # - When reporting url is provided, it means that the interactive is supposed to be saved as an URL.
    #   It's useful if state can be saved in the URL or is kept by the interactive itself (e.g. CODAP / docstore)
    # - Otherwise, interactive state JSON is sent to the Portal. Later, the same state will be provided to teacher report
    #   and sent to the interactive using LARA Interactive API.
    if interactive.has_report_url
      {
        "type" => "external_link",
        "question_type" => interactive.class.portal_type,
        "question_id" => interactive.id.to_s,
        # there is a chance that answer will be set to 'nil' here. That will happen
        # if there is no state or the state doesn't have a report url. In practice
        # this nil should not actually be sent to the portal because the
        # maybe_send_to_portal method below should only send it if reporting_url is present.
        "answer" => reporting_url,
        "is_final" => false
      }
    else
      {
        "type" => "interactive",
        "question_id" => interactive.id.to_s,
        "answer" => report_state.to_json,
        "is_final" => false
      }
    end
  end

  def maybe_send_to_portal
    if interactive.has_report_url
      send_to_portal if reporting_url.present?
    else
      send_to_portal if raw_data
    end
  end

  def reporting_url
    data = JSON.parse(raw_data) rescue {}
    (opts = data["lara_options"]) && opts["reporting_url"]
  end

  def report_state
    # Follow LARA Interactive API format. This state will be passed directly to the interactive later by the teacher
    # report app using iframe-phone `initInteractive` call. More properties can be provided here,
    # e.g. globalInteractiveState, linkedState and pretty much anything that is supported by `initInteractive`.
    # Please see LARA Interactive API docs or iframe-saver.coffee.
    # Note that Portal and Teacher Report app simply pass this state to the interactive, they don't know anything
    # about LARA Interactive API.
    {
      version: 1,
      mode: 'report',
      authoredState: interactive.authored_state,
      interactiveState: raw_data
    }
  end

  def has_linked_interactive
    (interactive.respond_to? :linked_interactive) && !interactive.linked_interactive.nil?
  end

  # this seems like it should be modeled as a through association, but perhaps it is hard because
  # interactives are polymorphic
  def find_linked_interactive_state
    return nil unless has_linked_interactive
    linked_interactive = interactive.linked_interactive
    runs = run.sequence_run ? run.sequence_run.runs : [run]
    InteractiveRunState.where(run_id: runs.map(&:id), interactive_id: linked_interactive.id).first
  end

  def linked_state
    return nil unless linked_state = find_linked_interactive_state
    linked_state.raw_data
  end

  # This alias makes #answer_json point at Embeddable::Answer#to_json (from inclusion of Embeddable::Answer at top)
  # ActiveRecord's #to_json had previously be aliased to #original_json. If we are called without arg, we send answer
  # json. Active Record Seiralization args are in the form of {methods: [method_names]} or {only: [field_names]} …
  alias_method :answer_json, :to_json
  def to_json(arg=nil)
    arg ? original_json(arg) : answer_json
  end

  def to_runtime_json()
    self.to_json({methods: [:linked_state, :has_linked_interactive]})
  end

  def answered?
    # if interactives have a reporting url they are answered only if that reporting url
    # is available. Otherwise any run state counts as answered.
    # Also note that even though interactive_run_states are considered polymorphic
    # they are actually only used by MwInteractive
    if interactive.has_report_url
      reporting_url.present?
    else
      raw_data.present?
    end
  end

  class AnswerStandin
    def initialize(opts={})
      q = question
      q.interactive = opts[:question] if opts[:question]
    end
    def question
      @question ||= QuestionStandin.new
    end
    def prompt
      question.prompt
    end
    def name
      question.name
    end
  end

  def self.default_answer(conditions)
    return AnswerStandin.new(conditions)
  end

  def add_key_if_nil
    self.key = InteractiveRunState.generate_key if self.key.nil?
  end
end
