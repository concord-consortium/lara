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

  def question
    interactive
  end

  def page
    interactive.interactive_page
  end

  def activity
    page && page.lightweight_activity
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

  def basic_answer_type_hash
    data = parsed_interactive_state
    basic_props = {
      id: answer_id,
      question_id: interactive.embeddable_id
    }
    if data["type"] === "open_response_answer"
      return basic_props.merge({question_type: "open_response"}).merge(data)
    end
    nil
  end

  def parsed_interactive_state
    JSON.parse(raw_data) rescue {}
  end

  def report_service_hash
    return basic_answer_type_hash if basic_answer_type_hash

    result = {
      id: answer_id,
      question_type: "iframe_interactive",
      question_id: interactive.embeddable_id
    }
    # There are two options how interactive can be saved in report service:
    # - When reporting url is provided, it means that the interactive is supposed to be saved as an URL.
    #   It's useful if state can be saved in the URL or is kept by the interactive itself (e.g. CODAP / docstore)
    # - Otherwise, interactive state JSON is sent to the Portal. Later, the same state will be provided to teacher report
    #   and sent to the interactive using LARA Interactive API.
    if interactive.has_report_url
      result[:type] = "external_link"
      result[:answer] = reporting_url
    else
      result[:type] = "interactive_state"
      result[:answer] = report_state.to_json
    end
    result
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

  # Returns all linked states. 1st element in the array is an interactive directly linked to given one.
  def all_linked_states(protocol = nil, host = nil)
    result = []
    current_interactive = interactive
    while (current_interactive.respond_to? :linked_interactive) && !current_interactive.linked_interactive.nil?
      linked_interactive = current_interactive.linked_interactive
      runs = run.sequence_run ? run.sequence_run.runs : [run]
      state = InteractiveRunState.where(run_id: runs.map(&:id), interactive_id: linked_interactive.id).first
      # It's not necessary to provide some metadata even for empty linked states, although it doesn't cost much
      # and it can be useful for interactive itself to know that there are some linked interactives,
      # but not run by student yet.
      linked_state_info = if state
                            state.to_runtime_hash(protocol, host, false)
                          else
                            { interactive_id: linked_interactive.id, raw_data: nil, created_at: nil, updated_at: nil }
                          end
      result.push(linked_state_info)
      # Go to the next interactive in linked interactives chain.
      current_interactive = linked_interactive
    end
    result
  end

  def linked_state
    # Note that this method will return the first available state of the linked interactives *chain*.
    # Sometimes the interactive that is directly linked might have not be run by student yet (e.g. when he skipped a page).
    non_empty_state = all_linked_states.find { |state| state[:raw_data] }
    unless non_empty_state.nil?
      return non_empty_state[:raw_data]
    end
    # Return nil if there's no linked state.
    nil
  end

  def run_remote_endpoint
    run.remote_endpoint
  end

  # This alias makes #answer_json point at Embeddable::Answer#to_json (from inclusion of Embeddable::Answer at top)
  # ActiveRecord's #to_json had previously be aliased to #original_json. If we are called without arg, we send answer
  # json. Active Record Seiralization args are in the form of {methods: [method_names]} or {only: [field_names]} …
  alias_method :answer_json, :to_json
  def to_json(arg=nil)
    arg ? original_json(arg) : answer_json
  end

  def to_runtime_hash(protocol, host, include_linked_states = true)
    hash = {
        id: id,
        key: key,
        raw_data: raw_data,
        learner_url: learner_url,
        run_remote_endpoint: run_remote_endpoint,
        interactive_state_url: interactive_state_url(protocol, host),
        interactive_id: interactive_id,
        interactive_name: interactive.name,
        page_number: page && page.page_number,
        page_name: page && page.name,
        activity_name: activity && activity.name,
        created_at: created_at,
        updated_at: updated_at
    }
    if include_linked_states
      hash[:has_linked_interactive] = has_linked_interactive
      hash[:linked_state] = linked_state
      hash[:all_linked_states] = all_linked_states(protocol, host)
    end

    hash
  end

  def to_runtime_json(protocol, host, include_linked_states = true)
    to_runtime_hash(protocol, host, include_linked_states).to_json
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

  def add_key_if_nil
    self.key = InteractiveRunState.generate_key if self.key.nil?
  end

  def interactive_state_url(protocol, host)
    if protocol && host
      Rails.application.routes.url_helpers.api_v1_show_interactive_run_state_url(key: self.key, protocol: protocol, host: host)
    else
      nil
    end
  end
end
