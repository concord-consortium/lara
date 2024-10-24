class CRater::ArgumentationBlocksController < ApplicationController
  CLAIM_HINT = """
  <b>Step 1: Select a claim.</b>
  <ul>
  <li>A good claim is based on the evidence.</li>
  <li>Evidence may come from graphs and charts.</li>
  <li>Evidence may also come from models that you run.</li>
  </ul>
  """

  EXPLANATION_HINT = """
  <b>Step 2: Write an explanation.</b>
  <ul>
  <li>A good explanation will cite specific evidence that backs up the claim.</li>
  <li>When there is a graph or table, you can cite evidence directly from the source.</li>
  <li>When there is a model, you can describe what happened in the model.</li>
  <li>A good explanation combines evidence with scientific knowledge.</li>
  </ul>
  """

  CERTAINTY_RATING_HINT = """
  <b>Step 3: Select a certainty rating.</b>
  <ul>
  <li>Picking a certainty rating is a way to signal how certain you are with your claim.</li>
  <li>Your certainty rating can be based on how well the scientific knowledge fits the evidence from models, charts, or graphs.</li>
  <li>Your certainty rating can also reflect on the quality of the evidence or investigation that produced the evidence.</li>
  </ul>
  """

  CERTAINTY_RATIONALE_HINT = """
  <b>Step 4: Write a certainty explanation.</b>
  <ul>
  <li>A good certainty explanation will explain why you are certain or uncertain about your response.</li>
  <li>Some topics are more certain than others.</li>
  <li>Consider the completeness of the evidence, biases in the evidence, and changes that could affect the trends over time.</li>
  </ul>
  """

  before_filter :set_page_and_authorize, only: [:create_embeddables, :remove_embeddables]
  skip_before_filter :verify_authenticity_token, only: [:report]

  def create_embeddables
    create_arg_block_embeddables(@page)
    redirect_to(:back)
  end

  def remove_embeddables
    @page.sections.where(title: CRater::ARG_SECTION_NAME).destroy_all
    redirect_to(:back)
  end

  def save_feedback
    page = InteractivePage.find(params[:page_id])
    run = Run.find_by_key(params[:run_key])
    feedback_info = CRater::FeedbackSubmission.generate_feedback(page, run)
    if request.xhr?
      render json: feedback_info
    else
      redirect_to(:back)
    end
  end

  def feedback_on_feedback
    submission = CRater::FeedbackSubmission.find(params[:submission_id])
    submission.update_usefulness_score(params[:score])
    if request.xhr?
      head(200)
    else
      redirect_to(:back)
    end
  end

  def report
    authorize! :manage, :all # admins

    # each row in report_data is a "bucket" for one student, and we want to fill each bucket with
    # time-sorted arg block submission data. Buckets should appear in the order they were sent to
    # us.

    arg_block_buckets = JSON.parse(params[:arg_block_buckets]).symbolize_keys!

    book = CRater::ArgumentationBlocksReport.generate(arg_block_buckets)
    sio = StringIO.new
    book.write sio
    send_data sio.string, :type => "application/vnd.ms.excel", :filename => "arg-block-report.xls"
  end

  private

  def set_page_and_authorize
    @page = InteractivePage.find(params[:page_id])
    @activity = @page.lightweight_activity
    authorize! :update, @page
    update_activity_changed_by
  end

  def create_arg_block_embeddables(page)
    mc1 = Embeddable::MultipleChoice.create(custom: true,
                                            hint: CLAIM_HINT,
                                            enable_check_answer: false)
    mc1.create_default_choices
    page.add_embeddable(mc1, 1, CRater::ARG_SECTION_NAME)

    or1 = Embeddable::OpenResponse.create(prompt: I18n.t('ARG_BLOCK.EXPLANATION_PROMPT'),
                                          hint: EXPLANATION_HINT)
    page.add_embeddable(or1, 2, CRater::ARG_SECTION_NAME)

    or1_c_rater_settings = CRater::ItemSettings.new(item_id: 'HENRY001')
    or1_c_rater_settings.score_mapping = CRater::ScoreMapping.explanation.last
    or1_c_rater_settings.provider = or1
    or1_c_rater_settings.save!

    mc2 = Embeddable::MultipleChoice.create(prompt: I18n.t('ARG_BLOCK.CERTAINTY_PROMPT'),
                                            hint: CERTAINTY_RATING_HINT,
                                            enable_check_answer: false,
                                            show_as_menu: true)
    mc2.add_choice("(1) #{I18n.t('ARG_BLOCK.NOT_CERTAIN')}")
    mc2.add_choice('(2)')
    mc2.add_choice('(3)')
    mc2.add_choice('(4)')
    mc2.add_choice("(5) #{I18n.t('ARG_BLOCK.VERY_CERTAIN')}")
    page.add_embeddable(mc2, 3, CRater::ARG_SECTION_NAME)

    or2 = Embeddable::OpenResponse.create(prompt: I18n.t('ARG_BLOCK.RATIONALE_PROMPT'),
                                          hint: CERTAINTY_RATIONALE_HINT)
    page.add_embeddable(or2, 4, CRater::ARG_SECTION_NAME)

    or2_c_rater_settings = CRater::ItemSettings.new(item_id: 'HENRY001')
    or2_c_rater_settings.score_mapping = CRater::ScoreMapping.rationale.last
    or2_c_rater_settings.provider = or2
    or2_c_rater_settings.save!
  end

end
