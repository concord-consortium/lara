module Embeddable
  QuestionTypes = {
    Embeddable::ImageQuestion  => "Image question",
    Embeddable::MultipleChoice => "Multiple choice",
    Embeddable::OpenResponse   => "Open response",
    Embeddable::Xhtml          => "Text box",
    Embeddable::Labbook        => "Labbook",
    QuestionTracker            => "Tracked Question",
    Embeddable::ExternalScript => "External Script",
    Embeddable::EmbeddablePlugin => "Plugin"
  }

  InteractiveTypes = {
    MwInteractive    => "Iframe Interactive",
    ImageInteractive => "Image",
    VideoInteractive => "Video"
  }

  # Types is just sum of question and interactives.
  Types = QuestionTypes.merge(InteractiveTypes)

  def self.is_question?(e)
    # Support both instance and class.
    QuestionTypes.keys.include?(e.class) || QuestionTypes.keys.include?(e)
  end

  def self.is_interactive?(e)
    # Support both instance and class.
    InteractiveTypes.keys.include?(e.class) || InteractiveTypes.keys.include?(e)
  end

  def self.table_name_prefix
    'embeddable_'
  end

  def self.valid_type(class_string)
    return Types.detect{|k,v| k.to_s == class_string }
  end

  def self.create_for_string(class_string)
    if self.valid_type(class_string)
      return class_string.constantize.create!
    else
      raise ArgumentError, 'Not a valid Embeddable type'
    end
    return nil
  end

  def p_item
    # Some embeddables define page_item, some page_items.
    # In practice, there's always just one page, so many to many relationship isn't necessary.
    respond_to?(:page_item) ? page_item : page_items.first
  end

  def page
    # Some embeddables define interactive_page, some interactive_pages.
    # In practice, there's always just one page, so many to many relationship isn't necessary.
    respond_to?(:interactive_page) ? interactive_page : interactive_pages.first
  end

  def activity
    page && page.lightweight_activity
  end

  # A unique key to use for local storage
  def storage_key
    # We're not actually using this at the moment (September 2013)
    if name.present?
      "#{interactive_pages.first.lightweight_activity.id}_#{interactive_pages.first.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}_#{name.downcase.gsub(/ /, '_')}"
    else
      "#{interactive_pages.first.lightweight_activity.id}_#{interactive_pages.first.id}_#{id}_#{self.class.to_s.underscore.gsub(/\//, '_')}"
    end
  end

  def show_in_runtime?
    true
  end

  # This should not take into account the hidden attribute. The caller should combine
  # is_hidden with reportable? to know what to show in a report
  def reportable?
    raise "#reportable? unimplemented for #{self.class}"
  end

  def index_in_activity(act = nil)
    if !act && !self.activity
      nil
    else
      (act ? act : self.activity).reportable_items.index(self) + 1
    end
  end

  # ID which is unique among all the embeddable types.
  def embeddable_dom_id
    "embeddable-#{self.class.to_s.demodulize.underscore}_#{self.id}"
  end

  # ID which is unique among all the embeddable types.
  def embeddable_id
    "#{self.class.to_s.demodulize.underscore}_#{self.id}"
  end
end
