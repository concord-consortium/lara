class DashboardRunlist

  def initialize(run_keys, page_id)
    @runs = Run.where(key: run_keys).map do |run|
      {
        key: run.key,
        submissions: submissions(run, page_id)
      }
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
        feedback: fi.feedback_text,
        score: fi.score
      }
    end
    answers.sort { |a,b| a[:question_index] <=> b[:question_index] }
  end

  def to_hash
    @runs
  end

  def to_json
    to_hash.to_json
  end
end
