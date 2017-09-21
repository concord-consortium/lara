text_fields = {
  "InteractivePage" => [
    :text,
    :name,
    :sidebar,
    :sidebar_title
  ],
  "ImageInteractive" => [
    :caption,
    :credit
  ],
  "LightweightActivity" => [
    :name,
    :description,
    :notes
  ],
  "MwInteractive" => [
    :name,
    :url,
    :image_url
  ],
  "Sequence" => [
    :description,
    :title,
    :display_title
  ],
  "VideoInteractive" => [
    :caption,
    :credit,
    :poster_url
  ],
  "VideoSource" => [
    :url
  ],
  "Embeddable::Xhtml" => [
    :name,
    :content
  ],
  "Embeddable::OpenResponse" => [
    :name,
    :prompt,
    :hint,
    :prediction_feedback,
    :default_text
  ],
  "Embeddable::MultipleChoice" => [
    :name,
    :prompt,
    :hint,
    :prediction_feedback
  ],
  "Embeddable::MultipleChoiceChoice" => [
    :choice,
    :prompt
  ],
  "Embeddable::Labbook" => [
    :name,
    :prompt,
    :hint
  ],
  "Embeddable::ImageQuestion" => [
    :name,
    :prompt,
    :hint,
    :drawing_prompt,
    :prediction_feedback
  ]
}

def find_text(model_class, field_name, text)
  model_class.constantize.where("#{field_name} like '%#{text}%'")
end

def replace_text(model, field_name, text, replacement)
  old_text = model.send(field_name.to_s)
  new_text = old_text.gsub(text, replacement)
  model.send("#{field_name}=".to_s, new_text)
  puts "+ replacing text of #{model.class.name}(#{model.id})##{field_name}"
  begin
    model.save!
  rescue
    puts "- failed to save #{model.class.name}(#{model.id})##{field_name}"
  end
end

def print_results(results, field_name, text)
  results.each do |model|
    found_text = model.send(field_name.to_s)
    highlighted = found_text.gsub(text,"\e[1m\\0\e[0m")
    puts "------------------"
    puts "#{model.class.name}(#{model.id})##{field_name} #{highlighted}"
  end
  nil
end

def matching_text(results, field_name, text, ending_character)
  matches = []
  results.each do |model|
    found_text = model.send(field_name.to_s)
    matches += found_text.scan(/#{text}[^#{ending_character}]*/)
  end
  matches
end

def find_and_print_all(text_fields, text)
  total = 0
  text_fields.each do |model_class, fields|
    fields.each do |field_sym|
      results = find_text(model_class, field_sym.to_s, text)
      total+= results.count
      print_results(results, field_sym.to_s, text)
    end
  end
  puts "------------"
  puts "Total Found: #{total}"
end

def find_all_unqiue_matches(text_fields, text, ending_character)
  matches = []
  text_fields.each do |model_class, fields|
    fields.each do |field_sym|
      results = find_text(model_class, field_sym.to_s, text)
      matches += matching_text(results, field_sym.to_s, text, ending_character)
    end
  end
  matches.uniq.sort
end

# https://s3.amazonaws.com/itsi-production/images-2009
# find_and_replace_all(text_fields, "http://itsi.portal.concord.org/system/images", "https://s3.amazonaws.com/itsi-production/images-2009")
def find_and_replace_all(text_fields, text, replacement)
  total = 0
  text_fields.each do |model_class, fields|
    fields.each do |field_sym|
      results = find_text(model_class, field_sym.to_s, text)
      puts "Found #{results.count} in #{model_class}##{field_sym.to_s}"
      total+= results.count
      results.each do |model|
        replace_text(model, field_sym.to_s, text, replacement)
      end
    end
  end
  puts "Total Found: #{total}"
end
