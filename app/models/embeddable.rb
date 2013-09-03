module Embeddable
  Types = {
      Embeddable::ImageQuestion  => "Image question",
      Embeddable::MultipleChoice => "Multiple choice",
      Embeddable::OpenResponse   => "Open response",
      Embeddable::Xhtml          => "Text area"
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
end
