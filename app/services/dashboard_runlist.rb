class DashboardRunlist
  DATA_VERSION = 2

  def initialize(endpoint_urls, page_id, submissions_created_after = 0)
    # DB query can be optimized by filtering out submissions older
    # than provided timestamp. If it's not provided (or nil), we will simply return all the submissions.
    submissions_created_after = Time.at(submissions_created_after ? submissions_created_after.to_i : 0)
    runs_data = Run.includes(:activity).where(remote_endpoint: endpoint_urls).map do |run|
      {
        endpoint_url: run.remote_endpoint,
        group_id: run.collaboration_run_id,
        last_page_id: run.page_id,
        submissions: submissions(run, page_id, submissions_created_after),
        sequence_id: run.sequence_id,
        updated_at: run.updated_at.to_i,
        activity_id: run.activity_id,
        page_ids: run.activity.page_ids
      }
    end
    @data = {
      runs: runs_data,
      # Timestamp can be used by the client to provide submissions_created_after param in the subsequent requests.
      timestamp: Time.now.to_i,
      version: DATA_VERSION
    }
  end

  def to_hash
    @data
  end

  def to_json
    to_hash.to_json
  end

  private

  def submissions(run, page_id, submissions_created_after)
    CRater::FeedbackSubmission
      .includes(
        c_rater_feedback_items: {answer: [:run, :question]},
        embeddable_feedback_items: {answer: [:run, :question]}
      )
      .where('created_at > ?', submissions_created_after)
      .where(
        run_id: run.id,
        interactive_page_id: page_id
      )
      .order(:id)
      .map do |submission|
      {
        id: submission.id,
        group_id: submission.collaboration_run_id,
        # Return time in milliseconds, so it's JS-friendly.
        created_at: submission.created_at.to_i * 1000,
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
        score: fi.score,
        max_score: fi.max_score
      }
    end
    answers.sort { |a,b| a[:question_index] <=> b[:question_index] }
  end
end
