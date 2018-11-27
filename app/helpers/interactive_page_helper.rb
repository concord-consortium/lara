module InteractivePageHelper
  def runnable_activity_page_path(activity, page)
    path_base = fetch_path_base(activity, @run, page)
    pass_white_list_params(path_base) if path_base
  end

  def fetch_path_base(activity, run, page)  # move me to be private.
    run = run_for_activity(activity, run)
    if run
      page_with_response_path(activity.id, page.id, run.key)
    elsif activity and page
      activity_page_path(activity, page)
    elsif activity
      activity_path(activity)
    else
       nil
    end
  end



  def page_link(activity,page, opts={})
    name = "Page #{page.position}"
    name = page.name unless page.name.blank?
    return link_to name, runnable_activity_page_path(activity,page), opts
  end

  def main_section_visible_embeddables(page, run)
    finder = Embeddable::AnswerFinder.new(run)
    # Limit visible embeddables to ones that do not belong to any section.
    # Don't return answer objects for interactives.
    page.main_visible_embeddables.map { |e| Embeddable::is_interactive?(e) ? e : finder.find_answer(e) }
  end

  def labbook_is_under_interactive?
    # Is the labbook is interleaved with interactions?
    if defined?(@labbook_is_under_interactive) && @labbook_is_under_interactive
      true
    else
      false
    end
  end

  def show_labbook_under_interactive?(run, interactive)
    # In single-page runtime, the labbook is interleaved with interactions
    return false unless labbook_is_under_interactive?
    return false if interactive.labbook.nil?
    return false if interactive.no_snapshots
    finder = Embeddable::AnswerFinder.new(run)
    return finder.find_answer(interactive.labbook)
  end

  # FIXME: false means the embeddable should be shown in the normal order
  #  in the assessment block. true means the embeddable is a labbook the activity
  #  is in a mode where embeddables are shown below the interactive
  def show_labbook_in_assessment_block?(embeddable_answer)
    question = embeddable_answer.respond_to?(:question) && embeddable_answer.question
    if question && question.is_a?(Embeddable::Labbook)
      return false unless question.interactive
      return labbook_is_under_interactive?
    end
    return false
  end

  def render_interactive(interactive)
    if interactive
      partial_name = "#{interactive.class.name.underscore.pluralize}/show"
      render partial: partial_name, locals: {interactive: interactive}
    end
  end

  protected
  def run_for_activity(activity, run)
    return nil unless run
    return run if (run.activity == activity)
    sequence_run = run.sequence_run
    return nil unless sequence_run
    return sequence_run.run_for_activity(activity)
  end
end
