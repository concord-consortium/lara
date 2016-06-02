class InteractiveRunState < ActiveRecord::Base
  alias_method :original_json, :to_json  # make sure we can still generate json of the base model after including Answer
  include Embeddable::Answer # Common methods for Answer models

  attr_accessible :interactive_id, :interactive_type, :run_id, :raw_data, :interactive, :run

  belongs_to :run
  belongs_to :interactive, :polymorphic => true

  after_update :maybe_send_to_portal

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

  def self.find_parent(run_state)
    interactive = run_state.interactive
    if ((interactive.respond_to? :parent) && interactive.parent)
      return self.by_run_and_interactive(run_state.run, interactive.parent)
    end
    return nil
  end

  # Make Embeddable::Answer assumptions work
  class QuestionStandin
    attr_accessor :interactive
    def name; "Interactive"; end
    def prompt; "Interactive"; end
    def is_prediction; false; end
    def give_prediction_feedback; false; end
    def prediction_feedback; nil; end
  end

  def question
    return @question if @question
    @question = QuestionStandin.new
    @question.interactive = interactive
    @question
  end

  def portal_hash
    {
      "type" => "external_link",
      "question_type" => interactive.class.name,
      "question_id" => interactive.id.to_s,
      "answer" => reporting_url,
      "is_final" => false
    }
  end

  def maybe_send_to_portal
    send_to_portal if reporting_url
  end

  def reporting_url
    data = JSON.parse(raw_data) rescue {}
    (opts = data["lara_options"]) && opts["reporting_url"]
  end

  def linked_state
    parent = self.class.find_parent(self)
    return nil unless parent
    return parent.raw_data
  end

  # This alias makes #answer_json point at Embeddable::Answer#to_json (from inclusion of Embeddable::Answer at top)
  # ActiveRecord's #to_json had previously be aliased to #original_json. If we are called without arg, we send answer
  # json. Active Record Seiralization args are in the form of {methods: [method_names]} or {only: [field_names]} …
  alias_method :answer_json, :to_json
  def to_json(arg=nil)
    arg ? original_json(arg) : answer_json
  end

  def to_runtime_json()
    self.to_json({methods: [:linked_state]})
  end

  def show_in_report?
    interactive.respond_to?('save_state') && interactive.save_state && interactive.respond_to?('has_report_url') && interactive.has_report_url
  end

  def answered?
    reporting_url.present?
  end

  class AnswerStandin
    attr_accessor :run
    def initialize(opts={})
      q = question
      q.interactive = opts[:question] if opts[:question]
      q.run = opts[:run] if opts[:run]
    end
    def question
      @question ||= QuestionStandin.new
    end
    def prompt
      question.prompt
    end
    def show_in_report?
      false
    end
  end

  def self.default_answer(conditions)
    return AnswerStandin.new
  end
end
