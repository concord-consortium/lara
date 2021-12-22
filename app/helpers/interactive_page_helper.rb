module InteractivePageHelper
  def runnable_activity_page_path(activity, page)
    path_base = fetch_path_base(@sequence, activity, @run, page)
    append_white_list_params(path_base) if path_base
  end

  def fetch_path_base(sequence, activity, run, page)  # move me to be private.
    run = run_for_activity(activity, run)
    if sequence and run and (sequence != run.sequence)
      raise Exception.new("Sequence and run sequence do not match!")
    end
    if run
      get_page_with_run_path(sequence, activity.id, page.id, run.key)
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

  def is_wrapping_plugin?(e)
    e.respond_to?(:wrapping_plugin?) && e.wrapping_plugin?
  end

  def main_section_wrapping_plugins(page, run)
    page.main_visible_embeddables.select { |e| is_wrapping_plugin?(e) }
  end

  def main_section_visible_embeddables(page, run)
    finder = Embeddable::AnswerFinder.new(run)
    # Limit visible embeddables to ones that do not belong to any section.
    # Don't return answer objects for interactives.
    page.main_visible_embeddables.map { |e| Embeddable::is_interactive?(e) ? e : finder.find_answer(e) }
  end

  def header_block_wrapping_plugins(page, run)
    page.header_block_visible_embeddables.select { |e| is_wrapping_plugin?(e) }
  end

  def header_block_visible_embeddables(page, run)
    finder = Embeddable::AnswerFinder.new(run)
    # Limit visible embeddables to ones that do not belong to any section.
    # Don't return answer objects for interactives.
    page.header_block_visible_embeddables.map { |e| Embeddable::is_interactive?(e) ? e : finder.find_answer(e) }
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

  def question_css_class(embeddable)
    is_likert = embeddable.is_a?(Embeddable::MultipleChoiceAnswer) && embeddable.is_likert
    css_class = embeddable.is_a?(Embeddable::Xhtml) ? 'challenge' : is_likert ? "likert" : ""
    css_class += embeddable.respond_to?(:is_callout) && embeddable.is_callout ? " callout" : ""
    css_class += embeddable.respond_to?(:is_half_width) && !embeddable.is_half_width ? " full-width-item" : ""
    css_class += is_wrapping_plugin?(embeddable) ? " hidden" : ""
    css_class
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
