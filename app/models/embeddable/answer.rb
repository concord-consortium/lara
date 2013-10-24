module Embeddable::Answer

  def self.by_run(r)
    where(:run_id => r.id)
  end

  @@question_index = nil
  def question_index
    if @@question_index.blank?
      begin
        self.run.activity.questions.index(self.question) + 1
      rescue StandardError => e
        logger.warn "Rescued #{e.class}: #{e.message}"
        return nil
      end
    else
      @@question_index
    end
  end

  @@cleaned_prompt = nil
  def prompt_no_itals
    if @@cleaned_prompt.blank?
      parsed_prompt = Nokogiri::HTML::DocumentFragment.parse(prompt)
      itals = parsed_prompt.at_css "i"
      if itals
        itals.content = nil
      end
      return parsed_prompt.to_html
    else
      return @@cleaned_prompt
    end
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