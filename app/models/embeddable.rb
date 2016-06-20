module Embeddable
  Types = {
      Embeddable::ImageQuestion  => "Image question",
      Embeddable::MultipleChoice => "Multiple choice",
      Embeddable::OpenResponse   => "Open response",
      Embeddable::Xhtml          => "Text box",
      Embeddable::Labbook        => "Labbook",
      QuestionTracker            => "Tracked Question"
    }

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

  def activity
    if interactive_pages.length > 0 && interactive_pages.first.lightweight_activity.present?
      return interactive_pages.first.lightweight_activity
    else
      return nil
    end
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

  def index_in_activity(activity)
    activity.reportable_items.index(self) + 1
  end
end
