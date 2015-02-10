module CRater::AuthoringHelper

  def arg_block_authorables(page)
    embeddables = page.section_embeddables(CRater::ARG_SECTION_NAME)
    # Return list of embeddables + C-Rater settings if available.
    embeddables.map { |e|
      e.respond_to?(:c_rater_settings) && e.c_rater_settings ? [e, e.c_rater_settings] : e
    }.flatten
  end
end
