class DashboardRunlist
  # If remote endpoint includes `key:` prefix, it means it's using long UUID key
  # instead of numeric ID, e.g.:
  # https://learn.concord.org/dataservice/external_activity_data/key:19679d16-e79e-4f36-8253-5deb1321e6d9
  SECURE_ENDPOINT_URL_REGEXP = /key:/

  def initialize(endpoint_urls, page_id)
    # Make sure that we accept only endpoints that use UUID to identify learner.
    # If we accepted numeric ID, it would be easy to modify it and download other students data.
    endpoint_urls = filter_endpoints(endpoint_urls)
    @runs = Run.where(remote_endpoint: endpoint_urls).map do |run|
      {
        endpoint_url: run.remote_endpoint,
        last_page_id: run.last_page ? run.last_page.id : nil,
        submissions: submissions(run, page_id)
      }
    end
  end

  def to_hash
    @runs
  end

  def to_json
    to_hash.to_json
  end

  private

  def filter_endpoints(endpoints)
    endpoints.select do |endpoint|
      endpoint =~ SECURE_ENDPOINT_URL_REGEXP
    end
  end

  def submissions(run, page_id)
    CRater::FeedbackSubmission.where(run_id: run.id, interactive_page_id: page_id).order(:id).map do |submission|
      {
        id: submission.id,
        answers: answers(submission)
      }
    end
  end

  def answers(submission)
    answers = submission.feedback_items.map do |fi|
      {
        question_index: fi.answer.question_index,
        answer: fi.answer_text,
        feedback_type: fi.class.name,
        feedback: fi.feedback_text,
        score: fi.score
      }
    end
    answers.sort { |a,b| a[:question_index] <=> b[:question_index] }
  end
end
