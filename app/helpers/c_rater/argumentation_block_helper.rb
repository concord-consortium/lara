module CRater::ArgumentationBlockHelper

  # Used during authoring.
  def arg_block_authorables(page)
    embeddables = page.section_embeddables(CRater::ARG_SECTION_NAME)
    # Return list of embeddables + C-Rater settings if available.
    embeddables.map { |e|
      e.respond_to?(:c_rater_settings) && e.c_rater_settings ? [e, e.c_rater_settings] : e
    }.flatten
  end

  # Used in runtime.
  def arg_block_embeddables(page, run)
    finder = Embeddable::AnswerFinder.new(run)
    page.section_embeddables(CRater::ARG_SECTION_NAME).map { |e| finder.find_answer(e) }
  end
end
