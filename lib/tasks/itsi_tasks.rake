require 'open-uri'

namespace :itsi do
  desc "Update width, height, and image_url of Interactives from the ITSI interactive library."
  task update_interactives: :environment do
    content = open(ENV['MODEL_JSON_LIST_URL']).read
    models = JSON.parse(content)["models"]
    total_count = 0
    total_wrong_name_count = 0
    models.each{|model|
      url = model["url"]
      print "Updating interactives: #{url}"
      count = 0
      # if the name doesn't match it is very likely that this interactive wasn't created through
      # the ITSI editor, so we don't want to mess with its width and height
      wrong_name_count = 0
      MwInteractive.find_all_by_url(url).each{|interactive|
      	if interactive.name != model["name"]
          wrong_name_count += 1
          next
      	end
        interactive.native_width = model["width"].to_i
        interactive.native_height = model["height"].to_i
        interactive.image_url = model["image_url"]
        interactive.save
        count += 1
      }

      # convert any interactives that are still http into https
      # this will not convert interactives aren't https
      http_url = url.sub("https://", "http://")
      MwInteractive.find_all_by_url(http_url).each{|interactive|
      	if interactive.name != model["name"]
          wrong_name_count += 1
          next
      	end
      	interactive.url = url
        interactive.native_width = model["width"].to_i
        interactive.native_height = model["height"].to_i
        interactive.image_url = model["image_url"]
        interactive.save
        count += 1
      }
      puts " updated: #{count}, unmatched name: #{wrong_name_count}"
      total_count += count
      total_wrong_name_count += wrong_name_count
    }
    puts "Total Updated: #{total_count}, Total with Wrong Name: #{total_wrong_name_count}"
  end

  desc "Reword the lab book prompts for itsi. See config/locales/en.yml  and Embeddable::Labbook#update_itsi_prompts"
  task update_labbook_prompts: :environment do
    Embeddable::Labbook.update_itsi_prompts
  end

end