module Embeddable::Answer
  def self.included base
    base.instance_eval do
      def self.by_run(r)
        where(:run_id => r.id)
      end
    end
  end

  @question_index = nil
  def question_index(skip_cache=false)
    # To skip the memoization and generate again, pass :true as an argument
    if skip_cache
      @question_index = nil
    end
    begin
      @question_index ||= self.run.activity.questions.index(self.question) + 1
    rescue StandardError => e
      logger.warn "Rescued #{e.class}: #{e.message}"
      return nil
    end
    @question_index
  end

  # Removes all content which is in italics from the prompt.
  # See https://www.pivotaltracker.com/story/show/50555355 for rationale.
  @cleaned_prompt = nil
  def prompt_no_itals(skip_cache=false)
    # To skip the memoization and generate again, pass :true as an argument
    if @cleaned_prompt.blank? || skip_cache
      parsed_prompt = Nokogiri::HTML::DocumentFragment.parse(prompt)
      itals = parsed_prompt.at_css "i"
      if itals
        itals.content = nil
      end
      @cleaned_prompt = parsed_prompt.to_html
    end
    return @cleaned_prompt
  end

  def send_to_portal(auth_key=nil)
    if run
      mark_dirty
      run.queue_for_portal(self, auth_key)
    end
  end

  def to_json
    portal_hash.to_json
  end

  def dirty?
    is_dirty?
  end

  def mark_dirty
    # wont invoke callbacks
    update_column(:is_dirty, true)
  end

  def mark_clean
    # wont invoke callbacks
    update_column(:is_dirty, false)
  end
end