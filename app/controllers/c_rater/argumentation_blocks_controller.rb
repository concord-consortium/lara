class CRater::ArgumentationBlocksController < ApplicationController
  before_filter :set_page_and_authorize, only: [:create_embeddables, :remove_embeddables]

  def create_embeddables
    create_arg_block_embeddables(@page)
    redirect_to(:back)
  end

  def remove_embeddables
    @page.page_items.where(section: CRater::ARG_SECTION_NAME).destroy_all
    redirect_to(:back)
  end

  def save_feedback
    # set_run_key expects @page and @activity to be set...
    @page = InteractivePage.find(params[:page_id])
    @activity = @page.lightweight_activity
    set_run_key # sets @run

    finder = Embeddable::AnswerFinder.new(@run)
    arg_block_answers = @page.section_embeddables(CRater::ARG_SECTION_NAME).map { |e| finder.find_answer(e) }
    feedback_items = {}
    submission = CRater::FeedbackSubmission.create!(interactive_page: @page, run: @run)
    arg_block_answers.each do |a|
      f = a.save_feedback
      unless f.nil?
        f.feedback_submission = submission
        f.save!
        feedback_items[a.id] = {score: f.score, text: f.feedback_text}
      end
    end

    if request.xhr?
      render json: {
               submission_id: submission.id,
               feedback_items: feedback_items
             }
    else
      redirect_to(:back)
    end
  end

  def feedback_on_feedback
    submission = CRater::FeedbackSubmission.find(params[:submission_id])
    submission.update_attributes!(usefulness_score: params[:score])
    if request.xhr?
      head(200)
    else
      redirect_to(:back)
    end
  end

  def report
    authorize! :manage, :all # admins
    # Start with a list of endpoints; here we just use all of them
    endpoints = Run.where("remote_endpoint IS NOT NULL").map &:remote_endpoint

    select_params = [
      {
        :embeddable_type => "Embeddable::OpenResponse",
        :embeddable_table => "embeddable_open_responses",
        :answer_table => "embeddable_open_response_answers",
        :question_foreign_key => "open_response_id",
        :feedback_table => "c_rater_feedback_items",
        :usefulness_score_column => "c_rater_feedback_submissions.usefulness_score",
        :usefulness_score_join => "LEFT OUTER JOIN c_rater_feedback_submissions ON c_rater_feedback_submissions.id = c_rater_feedback_items.feedback_submission_id"
      },
      {
        :embeddable_type => "Embeddable::MultipleChoice",
        :embeddable_table => "embeddable_multiple_choices",
        :answer_table => "embeddable_multiple_choice_answers",
        :question_foreign_key => "multiple_choice_id",
        :feedback_table => "embeddable_feedback_items",
        :usefulness_score_column => "NULL",
        :usefulness_score_join => ""
      }
    ]

    selects = select_params.map do |s|
      select = <<SQL
        SELECT DISTINCT
        runs.remote_endpoint AS remote_endpoint,
        lightweight_activities.id AS activity_id,
        interactive_pages.id AS page_id,
        interactive_pages.position AS page_index,
        page_items.position AS question_index,
        #{s[:embeddable_table]}.id AS question_id,
        #{s[:embeddable_table]}.prompt AS prompt,
        #{s[:feedback_table]}.answer_text AS answer,
        #{s[:feedback_table]}.score AS score,
        #{s[:feedback_table]}.created_at AS submit_time,
        #{s[:feedback_table]}.feedback_text AS feedback,
        #{s[:usefulness_score_column]} AS usefulness_score
      FROM runs
        INNER JOIN lightweight_activities
          ON lightweight_activities.id = runs.activity_id
        INNER JOIN interactive_pages
          ON interactive_pages.lightweight_activity_id = lightweight_activities.id
        INNER JOIN page_items
          ON page_items.interactive_page_id = interactive_pages.id
        INNER JOIN #{s[:embeddable_table]}
          ON #{s[:embeddable_table]}.id = page_items.embeddable_id
        LEFT OUTER JOIN #{s[:answer_table]}
          ON #{s[:answer_table]}.run_id = runs.id AND #{s[:answer_table]}.#{s[:question_foreign_key]} = #{s[:embeddable_table]}.id
        LEFT OUTER JOIN #{s[:feedback_table]}
          ON #{s[:feedback_table]}.answer_id = #{s[:answer_table]}.id
        #{s[:usefulness_score_join]}
      WHERE
        page_items.section = "arg_block"
        AND
        embeddable_type = "#{s[:embeddable_type]}"
        AND
        remote_endpoint in ("#{endpoints.join('","')}")
SQL
    end

    order_by = <<SQL
      ORDER BY
        activity_id,
        remote_endpoint,
        submit_time
SQL

    sql = selects.join("\n UNION\n") + order_by + ";"

    results = ActiveRecord::Base.connection.execute(sql)

    # Mysql2::Results doesn't support #map
    out = ""
    results.each { |r| out += r.to_yaml }
    render :text => out, :content_type => "text/plain"
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
                                            enable_check_answer: false)
    mc1.create_default_choices
    page.add_embeddable(mc1, 0, CRater::ARG_SECTION_NAME)

    or1 = Embeddable::OpenResponse.create(prompt: I18n.t('ARG_BLOCK.EXPLANATION_PROMPT'))
    page.add_embeddable(or1, 1, CRater::ARG_SECTION_NAME)

    or1_c_rater_settings = CRater::ItemSettings.new(item_id: 'HENRY001')
    or1_c_rater_settings.score_mapping = CRater::ScoreMapping.explanation.last
    or1_c_rater_settings.provider = or1
    or1_c_rater_settings.save!

    mc2 = Embeddable::MultipleChoice.create(prompt: I18n.t('ARG_BLOCK.CERTAINTY_PROMPT'),
                                            enable_check_answer: false,
                                            show_as_menu: true)
    mc2.add_choice("(1) #{I18n.t('ARG_BLOCK.NOT_CERTAIN')}")
    mc2.add_choice('(2)')
    mc2.add_choice('(3)')
    mc2.add_choice('(4)')
    mc2.add_choice("(5) #{I18n.t('ARG_BLOCK.VERY_CERTAIN')}")
    page.add_embeddable(mc2, 2, CRater::ARG_SECTION_NAME)

    or2 = Embeddable::OpenResponse.create(prompt: I18n.t('ARG_BLOCK.RATIONALE_PROMPT'))
    page.add_embeddable(or2, 3, CRater::ARG_SECTION_NAME)

    or2_c_rater_settings = CRater::ItemSettings.new(item_id: 'HENRY001')
    or2_c_rater_settings.score_mapping = CRater::ScoreMapping.rationale.last
    or2_c_rater_settings.provider = or2
    or2_c_rater_settings.save!
  end
end
