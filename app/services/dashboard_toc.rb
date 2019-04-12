class DashboardToc

  class FauxSequence
    def initialize(activity)
      @activity = activity
    end

    def activities
      [ @activity ]
    end
    def title
      @activity.name
    end
  end

  include LightweightStandalone::Application.routes.url_helpers

  def initialize(activity_or_sequence)
    case activity_or_sequence
      when Sequence
        @sequence = activity_or_sequence
      else
        @sequence = FauxSequence.new(activity_or_sequence)
    end
  end

  def to_hash
      {
        name: @sequence.title,
        url: url,
        activities: @sequence.activities.map { |a| activity_to_hash(a) }
      }
  end

  def to_json
    to_hash.to_json
  end


  private
  def url
    if @sequence.activities.empty?
      if @sequence_run
        return sequence_with_sequence_run_key_path(@sequence, @sequence_run.key)
      else
        return sequence_path(@sequence)
      end
    else
      return activity_path(@sequence.activities.first)
    end

  end
  def questions(page)
    questions = page.section_embeddables(CRater::ARG_SECTION_NAME).map do |q|
      choices = []
      if q.respond_to? :choices
        choices = q.choices.map { |c| c.choice }
      end
      {
          index: q.index_in_activity(page.lightweight_activity),
          name: q.name,
          prompt: q.prompt,
          choices: choices
      }
    end
    questions.sort! { |a,b| a[:index] <=> b[:index] }
  end

  def page_to_hash(page)
    {
        name: page.name,
        id: page.id,
        url: activity_page_path(id: page.id, activity_id: page.lightweight_activity.id),
        questions: questions(page)
    }
  end

  # Create a Table Of Contents for this activity
  def activity_to_hash(activity)
    pages = activity.visible_pages_with_embeddables.map { |p| page_to_hash(p) }
    {
        name: activity.name,
        url: activity_path(id: activity.id),
        id: activity.id,
        pages: pages
    }
  end


end
