class DashboardSequenceRunlist
  DATA_VERSION = 2

    # We return a structure like this:
    # [
    #     {
    #       "endpoint_url": "http://someplace.com/u/fsdfsf",
    #       "answers": [
    #         {
    #           "page": "Page 1",
    #           "pageId": 1,
    #           "pageIndex": 0,
    #           "tryCount": 0,
    #           "numQuestions": 4,
    #           "answers": []
    #         }, …
    #       ]
    #     }, …
    # ]

  def initialize(endpoint_urls, submissions_created_after = 0, sequence_run=true)
    # DB query can be optimized by filtering out submissions older
    # than provided timestamp. If it's not provided (or nil), we will simply return all the submissions.
    # for now we assume its a sequence run...
    submissions_created_after = Time.at(submissions_created_after ? submissions_created_after.to_i : 0)
    runs = []
    runs_data =[]
    if sequence_run
      runs = SequenceRun.includes(:runs).where(remote_endpoint: endpoint_urls)
      runs_data = runs.flat_map do |sequence_run|
        max_updated_at = sequence_run.runs.map { |r| r.updated_at }.max
        sequence_run.runs.map do |run|
          {
            endpoint_url: run.remote_endpoint,
            answers: run_answers(run, submissions_created_after),
            updated_at: max_updated_at.to_i,
          }
        end
      end
    else

      runs = Run.where(remote_endpoint: endpoint_urls)
      runs_data = runs.map do |run|
        {
          endpoint_url: run.remote_endpoint,
          answers: run_answers(run, submissions_created_after),
          updated_at: run.updated_at.to_i,
        }
      end
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

  def run_answers(run, submissions_created_after)
    submissions = CRater::FeedbackSubmission
      .includes(
        c_rater_feedback_items: {answer: [:run, :question]},
        embeddable_feedback_items: {answer: [:run, :question]}
      )
      .where('created_at > ?', submissions_created_after)
      .where(run_id: run.id)
      .order(:id)
    num_tries = submissions.length
    if num_tries < 1
      return []
    end
    submission = submissions.last
    return {
      page: submission.interactive_page_id,
      pageIndex: submission.interactive_page.position,
      tryCount: num_tries,
      numQuestions: 4,
      answers: submission_answers(submission)
    }
  end

  def submission_answers(submission)
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
