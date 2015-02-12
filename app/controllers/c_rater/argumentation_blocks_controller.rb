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
    set_run_key

    finder = Embeddable::AnswerFinder.new(@run)
    arg_block_answers = @page.section_embeddables(CRater::ARG_SECTION_NAME).map { |e| finder.find_answer(e) }
    feedback_items = {}
    arg_block_answers.each do |a|
      f = a.save_feedback
      feedback_items[a.id] = {score: f.score, text: f.feedback_text} if f
    end

    if request.xhr?
      render json: feedback_items
    else
      redirect_to(:back)
    end
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

    or1 = Embeddable::OpenResponse.create(prompt: 'Explain your answer.')
    page.add_embeddable(or1, 1, CRater::ARG_SECTION_NAME)

    or1_c_rater_settings = CRater::ItemSettings.new(item_id: 'HENRY001')
    or1_c_rater_settings.provider = or1
    or1_c_rater_settings.save!

    mc2 = Embeddable::MultipleChoice.create(prompt: 'How certain are you about your claim based on your explanation?',
                                            enable_check_answer: false,
                                            show_as_menu: true)
    mc2.add_choice('(1) Not at all certain')
    mc2.add_choice('(2)')
    mc2.add_choice('(3)')
    mc2.add_choice('(4)')
    mc2.add_choice('(5) Very certain')
    page.add_embeddable(mc2, 2, CRater::ARG_SECTION_NAME)

    or2 = Embeddable::OpenResponse.create(prompt: 'Explain what influenced your certainty rating.')
    page.add_embeddable(or2, 3, CRater::ARG_SECTION_NAME)

    or2_c_rater_settings = CRater::ItemSettings.new(item_id: 'HENRY001')
    or2_c_rater_settings.provider = or2
    or2_c_rater_settings.save!
  end
end
