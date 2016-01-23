class DashboardRunlist
  def initialize(endpoint_urls, page_id)
    @runs = Run.where(remote_endpoint: endpoint_urls).map do |run|
      {
        endpoint_url: run.remote_endpoint,
        group_id: run.collaboration_run_id,
        last_page_id: run.page_id,
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

  def submissions(run, page_id)
    CRater::FeedbackSubmission.where(run_id: run.id, interactive_page_id: page_id).order(:id).map do |submission|
      {
        id: submission.id,
        group_id: submission.collaboration_run_id,
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
