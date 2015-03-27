module InteractivePageHelper
  def runnable_activity_page_path(activity, page)
    run = run_for_activity(activity,@run)
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

  def main_section_embeddables(page, run)
    finder = Embeddable::AnswerFinder.new(run)
    # Limit embeddables to ones that do not belong to any section.
    page.main_embeddables.map { |e| finder.find_answer(e) }
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
