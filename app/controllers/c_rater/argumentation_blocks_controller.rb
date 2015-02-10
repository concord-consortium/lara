class CRater::ArgumentationBlocksController < ApplicationController
  before_filter :set_page_and_authorize

  def create_embeddables
    create_arg_block_embeddables(@page)
    redirect_to(:back)
  end

  def remove_embeddables
    @page.page_items.where(section: CRater::ARG_SECTION_NAME).destroy_all
    redirect_to(:back)
  end

  private

  def set_page_and_authorize
    @page = InteractivePage.find(params[:page_id])
    @activity = @page.lightweight_activity
    authorize! :update, @page
    update_activity_changed_by
  end

  def create_arg_block_embeddables(page)
    mc1 = Embeddable::MultipleChoice.create(custom: true)
    mc1.create_default_choices
    page.add_embeddable(mc1, 0, CRater::ARG_SECTION_NAME)

    or1 = Embeddable::OpenResponse.create(prompt: 'Explain your answer.')
    page.add_embeddable(or1, 1, CRater::ARG_SECTION_NAME)

    or1_c_rater_settings = CRater::Settings.new(item_id: 'HENRY001')
    or1_c_rater_settings.provider = or1
    or1_c_rater_settings.save!

    mc2 = Embeddable::MultipleChoice.create(prompt: 'How certain are you about your claim based on your explanation?',
                                            show_as_menu: true)
    mc2.add_choice('(1) Not at all certain')
    mc2.add_choice('(2)')
    mc2.add_choice('(3)')
    mc2.add_choice('(4)')
    mc2.add_choice('(5) Very certain')
    page.add_embeddable(mc2, 2, CRater::ARG_SECTION_NAME)

    or2 = Embeddable::OpenResponse.create(prompt: 'Explain what influenced your certainty rating.')
    page.add_embeddable(or2, 3, CRater::ARG_SECTION_NAME)

    or2_c_rater_settings = CRater::Settings.create(item_id: 'HENRY001')
    or2_c_rater_settings.provider = or2
    or2_c_rater_settings.save!
  end
end
