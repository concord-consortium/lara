class HtmlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    temp_xml = Nokogiri::XML "<div>#{value}</div>" # Wrap in a div so we can validate plain-text inputs
    temp_xml.errors.each { |err| record.errors.add attribute, err.to_s unless err.none? }
  end
end