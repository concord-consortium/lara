class CRater::ArgumentationBlocksController < ApplicationController

  require 'nokogiri'
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'

  before_filter :set_page_and_authorize, only: [:create_embeddables, :remove_embeddables]
  skip_before_filter :verify_authenticity_token, only: [:report]

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

    report_data = JSON.parse(params[:arg_block_data]).symbolize_keys!
    report_data[:headers] = report_data[:headers].map &:to_sym

    # each row in report_data is a "bucket" for one student, and we want to fill each bucket with time-sorted
    # arg block submission data. Buckets should appear in the order they were sent to us.

    remote_endpoint_index = report_data[:headers].find_index(:remote_endpoint)
    bucket_by_remote_endpoint = {}
    num_buckets = report_data[:rows].length
    all_remote_endpoints = []
    report_data[:rows].each_with_index do |row, bucket_index|
      row[remote_endpoint_index].each do |endpoint|
        bucket_by_remote_endpoint[endpoint] = bucket_index
        all_remote_endpoints.push(endpoint)
      end
    end

    select_params = [
      {
        :embeddable_type => "Embeddable::OpenResponse",
        :embeddable_table => "embeddable_open_responses",
        :answer_table => "embeddable_open_response_answers",
        :question_foreign_key => "open_response_id",
        :feedback_table => "c_rater_feedback_items"
      },
      {
        :embeddable_type => "Embeddable::MultipleChoice",
        :embeddable_table => "embeddable_multiple_choices",
        :answer_table => "embeddable_multiple_choice_answers",
        :question_foreign_key => "multiple_choice_id",
        :feedback_table => "embeddable_feedback_items"
      }
    ]

    selects = select_params.map do |s|
      select = <<SQL
        SELECT DISTINCT
        runs.remote_endpoint AS remote_endpoint,
        c_rater_feedback_submissions.created_at AS submission_time,
        c_rater_feedback_submissions.id AS submission_id,
        lightweight_activities.name as activity_name,
        lightweight_activities.id AS activity_id,
        interactive_pages.id AS page_id,
        interactive_pages.position + 1 AS page_index,
        page_items.position + 1 AS question_index,
        #{s[:embeddable_table]}.id AS question_id,
        #{s[:embeddable_table]}.prompt AS prompt,
        #{s[:feedback_table]}.answer_text AS answer,
        #{s[:feedback_table]}.score AS score,
        #{s[:feedback_table]}.feedback_text AS feedback,
        c_rater_feedback_submissions.usefulness_score AS usefulness_score
      FROM runs
        INNER JOIN lightweight_activities
          ON lightweight_activities.id = runs.activity_id
        INNER JOIN interactive_pages
          ON interactive_pages.lightweight_activity_id = lightweight_activities.id
        INNER JOIN page_items
          ON page_items.interactive_page_id = interactive_pages.id
        INNER JOIN #{s[:embeddable_table]}
          ON #{s[:embeddable_table]}.id = page_items.embeddable_id
        INNER JOIN #{s[:answer_table]}
          ON #{s[:answer_table]}.run_id = runs.id AND #{s[:answer_table]}.#{s[:question_foreign_key]} = #{s[:embeddable_table]}.id
        INNER JOIN #{s[:feedback_table]}
          ON #{s[:feedback_table]}.answer_id = #{s[:answer_table]}.id
        INNER JOIN c_rater_feedback_submissions
          ON c_rater_feedback_submissions.id = #{s[:feedback_table]}.feedback_submission_id 
      WHERE
        page_items.section = "arg_block"
        AND
        embeddable_type = "#{s[:embeddable_type]}"
        AND
        remote_endpoint in ("#{all_remote_endpoints.join('","')}")
SQL
    end

    order_by = <<SQL
      ORDER BY
        submission_time,
        submission_id
SQL

    sql = selects.join("\n UNION\n") + order_by + ";"
    result = ActiveRecord::Base.connection.exec_query(sql)
    result_columns = result.columns.map &:to_sym

    remote_endpoint_index = result_columns.find_index(:remote_endpoint)
    page_id_index = result_columns.find_index(:page_id)
    question_index_index = result_columns.find_index(:question_index)
    submission_id_index = result_columns.find_index(:submission_id)

    student_buckets = Array.new(num_buckets) { [] }  # num_buckets *distinct* empty arrays
    question_indices_by_page_id = {}

    # divvy results into buckets, preserving existing result ordering within each bucket
    # also keep track of question indices
    result.rows.each do |row|
      endpoint = row[remote_endpoint_index]
      bucket = student_buckets[bucket_by_remote_endpoint[endpoint]]
      bucket.push(row)

      page_id = row[page_id_index]
      question_index = row[question_index_index]
      question_indices_by_page_id[page_id] ||= Set.new
      question_indices_by_page_id[page_id].add(question_index)
    end

    question_index_map_by_page_id = {}
    question_indices_by_page_id.keys.each do |page_id|
      s = question_indices_by_page_id[page_id]
      question_index_map_by_page_id[page_id] = Hash[(0...s.size).zip(s.to_a.sort)].invert
    end

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => 'Long Format'

    # now all buckets are filled and all indices are found
    row_index = 0
    row = nil
    previous_submission_id = nil

    report_data[:rows].each_with_index do |bucket_prefix, bucket_index|
      student_buckets[bucket_index].each do |bucket_row|
        # create one spreadsheet row for every submission
        if bucket_row[submission_id_index] != previous_submission_id
          previous_submission_id = bucket_row[submission_id_index]
          row = sheet.row(row_index)
          row_index += 1
          row.push(*bucket_prefix)
          row.push(*bucket_row[1...7])
          # usefulness score
          row[bucket_prefix.length + 6 + 4 * 5] = bucket_row.last
        end

        page_id = bucket_row[page_id_index]
        fixed_question_index = question_index_map_by_page_id[page_id][bucket_row[question_index_index]]
        start_index = bucket_prefix.length + 6 + (fixed_question_index * 5)
        end_index = start_index + 5
        row[start_index...end_index] = bucket_row[8...13]
      end
    end

    # header_name_for_sql_column = {
    #   "remote_endpoint"  => "remote_endpoint",
    #   "submission_time"  => "Submission time",
    #   "submission_id"    => "Submission ID",
    #   "activity_name"    => "Activity Name",
    #   "activity_id"      => "Activity ID",
    #   "page_id"          => "Page ID",
    #   "page_index"       => "Page Index",
    #   "question_id"      => "Question ID",
    #   "question_index"   => "Question Index",
    #   "prompt"           => "Prompt",
    #   "answer"           => "Answer",
    #   "score"            => "Score",
    #   "feedback"         => "Feedback",
    #   "usefulness_score" => "Usefulness score"
    # }


    # row = sheet.row(0)

    # result.columns.each do |col|
    #   row.push header_name_for_sql_column[col]
    # end

    # result.each_with_index do |row_as_hash, row_idx|
    #   row_values = row_as_hash.values.map do |cell|
    #     cell.class == String ? clean_text(cell) : cell
    #   end
    #   sheet.row(row_idx + 1).replace row_values  # + 1 to leave a blank line under header
    # end

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

  def clean_text(html)
    return Nokogiri::HTML(html).inner_text
  end

end
