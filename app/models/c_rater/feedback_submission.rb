class CRater::FeedbackSubmission < ApplicationRecord

  has_many :c_rater_feedback_items, as: :feedback_submission, class_name: 'CRater::FeedbackItem'
  has_many :embeddable_feedback_items, as: :feedback_submission, class_name: 'Embeddable::FeedbackItem'
  belongs_to :interactive_page
  belongs_to :run
  belongs_to :collaboration_run
  belongs_to :base_submission, class_name: 'CRater::FeedbackSubmission'

  delegate :user, to: :run, allow_nil: true

  def self.usefulness_score_names
    {
      0 => I18n.t('ARG_BLOCK.USEFUL_0'),
      1 => I18n.t('ARG_BLOCK.USEFUL_1'),
      2 => I18n.t('ARG_BLOCK.USEFUL_2')
    }
  end

  # For given page and run, generates feedback for all the argumentation block questions,
  # creates a new submission and returns a hash with basic information about submission.
  def self.generate_feedback(page, run)
    finder = Embeddable::AnswerFinder.new(run)
    arg_block_answers = page.section_embeddables(CRater::ARG_SECTION_NAME).map { |e| finder.find_answer(e) }
    submission = CRater::FeedbackSubmission.create!(interactive_page: page, run: run, collaboration_run: run.collaboration_run)
    feedback_items = {}
    arg_block_answers.each do |a|
      f = a.save_feedback
      unless f.nil?
        f.feedback_submission = submission
        f.save!
        # a.answer_id is unique among all the answer types, e.g. open_response_answer_123, multiple_choice_answer_321.
        feedback_items[a.answer_id] = {score: f.score, text: f.feedback_text, max_score: f.max_score, error: f.error?}
      end
    end
    submission.propagate_to_collaborators
    {
      submission_id: submission.id,
      feedback_items: feedback_items
    }
  end

  def usefulness_score_name
    self.class.usefulness_score_names[usefulness_score]
  end

  def feedback_items
    c_rater_feedback_items + embeddable_feedback_items
  end

  def update_usefulness_score(value)
    update_attributes!(usefulness_score: value)
    if collaboration_run
      CRater::FeedbackSubmission.where(base_submission_id: self.id).each do |submission|
        submission.update_attributes!(usefulness_score: value)
      end
    end
  end

  def activity
    interactive_page && interactive_page.lightweight_activity
  end

  def propagate_to_collaborators
    return unless collaboration_run
    collaboration_run.collaborators_runs(activity, user).each do |run|
      submission_copy = self.dup
      submission_copy.run = run
      submission_copy.base_submission = self
      submission_copy.save!
      finder = Embeddable::AnswerFinder.new(run)
      feedback_items.each do |fi|
        fi_copy = fi.dup
        fi_copy.feedback_submission = submission_copy
        fi_copy.answer = finder.find_answer(fi.answer.question)
        fi_copy.save!
      end
    end
  end

  def any_errors?
    feedback_items.any? {|fi| fi.error? }
  end
end
