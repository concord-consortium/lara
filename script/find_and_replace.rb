text_fields = {
  "InteractivePage" => [
    :name,
    :sidebar,
    :sidebar_title
  ],
  "ImageInteractive" => [
    :caption,
    :credit,
    :url
  ],
  "LightweightActivity" => [
    :name,
    :description,
    :notes,
    :thumbnail_url
  ],
  "MwInteractive" => [
    :name,
    :url,
    :image_url
  ],
  "Sequence" => [
    :description,
    :title,
    :display_title,
    :thumbnail_url
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

interactive_url_field = {
  "MwInteractive" => [
    :url
  ]
}

def find_text(model_class, field_name, text)
  model_class.constantize.where("#{field_name} like '%#{text}%'")
end

def replace_text(model, field_name, text, replacement, dry_run=false)
  old_text = model.send(field_name.to_s)
  new_text = old_text.gsub(text, replacement)
  if dry_run
    puts "+ would replace text of #{model.class.name}(#{model.id})##{field_name}"
    puts "  old #{old_text}"
    puts "  new #{new_text}"
    return
  end
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

# Replace text in all the specificed text fields
# There is a `text_fields` global defined above that specifies the fields of each model
# So this an example usage:
#   find_and_replace_all(text_fields, "http://itsi.portal.concord.org/system/images", "https://s3.amazonaws.com/itsi-production/images-2009")
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

# 2 ways to find http interactives
interactives = MwInteractive.where("url like '%http://%'"); nil
interactives = find_text("MwInteractive", :url, "http://"); nil

# Filter out interactives that don't have pages or don't have activities
interactives = interactives.all.select{|i| i.interactive_page}; nil
interactives = interactives.all.select{|i| i.interactive_page.lightweight_activity}; nil

# create an array of interactive info
def interactive_info(i)
  info = [];
  (2013..2019).each{|year|
    info << i.interactive_page.lightweight_activity.runs.where(updated_at: Date.new(year)..Date.new(year+1)).count
  }
  info << i.interactive_page.lightweight_activity.runs.where(updated_at: Date.new(2020)..Date.today).count

  info << i.interactive_page.lightweight_activity.runs.count
  info << i.id
  info << i.interactive_page.lightweight_activity.id
  info << i.url
  info
end

def print_interactives_csv(interactives)
  results = interactives.map{|i| interactive_info(i)}; nil

  # add header
  headers = Array(2013..2019) + ['2020 on', 'total runs count', 'id', 'activity id', 'url']
  results.unshift(headers); nil

  require 'csv'
  puts results.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""); nil
end

# replacing the http with https (note this will also replace these within the URL if it has them as a parameter
interactives.each{|i| replace_text(i, :url, 'http://', 'https://')}; nil

# replace interactive with a button interactive that opens it in a new window
def replace_with_button(interactive)
  old_url = interactive.url
  interactive.url = "https://concord-consortium.github.io/button-interactive/"
  interactive.authored_state = {
    version: "1.0",
    description: "This component no longer works embedded in the page. Use the button below to open it in a new window.",
    url: old_url,
    label: "Open ➚"
  }.to_json
  interactive.save!
end

# to get the unicode arrow in the button text above, the following variables
# need to be set first before running the rails console
LANG="C.UTF-8"
LC_COLLATE="C.UTF-8"
LC_CTYPE="C.UTF-8"
LC_MESSAGES="C.UTF-8"
LC_MONETARY="C.UTF-8"
LC_NUMERIC="C.UTF-8"
LC_TIME="C.UTF-8"
LC_ALL="C.UTF-8"
export LANG LC_COLLATE LC_CTYPE LC_MESSAGES LC_MONETARY LC_NUMERIC LC_TIME LC_ALL

# print interactives and highlight any escaped http urls
print_results(interactives, :url, 'http%3A')

# replace esacped http urls
interactives.each{|i| replace_text(i, :url, 'http%3A', 'https%3A')}
