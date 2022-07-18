
@convertable_embeddable_types = [
  "Multiple Choice",
  "Open Response",
  "Image Interactive",
  "Video Player",
  "Image Question"
]

@convertable_embeddable_classes = [
  "Embeddable::MultipleChoice",
  "Embeddable::OpenResponse",
  "ImageInteractive",
  "VideoInteractive",
  "Embeddable::ImageQuestion"
]

not_convertable_question_types = []

def count_embeddables()
  # Get a count of all built-in embeddables that need to be converted.
  embeddables_count = 0
  PageItem.all.each do |item|
    if @convertable_embeddable_classes.include? item.embeddable_type
      embeddables_count += 1
    end
  end
  puts "There are #{embeddables_count} built-in embeddables to convert."
end

def convert_multiple_choice(item, library_interactive)
  name = item.embeddable.name != "Multiple Choice Question element" ? item.embeddable.name : ""
  choice_id = 1
  converted_choices = []
  item.embeddable.choices.each do |choice|
    converted_choice = {
      id: choice_id,
      content: choice.choice,
      correct: choice.is_correct,
      choiceFeedback: choice.prompt
    }
    converted_choices.push(converted_choice)
    choice_id += 1
  end

  layout = item.embeddable.show_as_menu ? "Dropdown" : item.embeddable.layout
  
  authored_state = {
    version: 1,
    questionType: "multiple_choice",
    choices: converted_choices,
    layout: layout
  }

  authored_state_properties = {
    prompt: "prompt",
    enable_check_answer: "enableCheckAnswer",
    is_prediction: "required",
    multi_answer: "multipleAnswers",
    hint: "hint",
    give_prediction_feedback: "customFeedback",
    prediction_feedback: "predictionFeedback"
  }
  
  authored_state_properties.each do |key, value|
    if item.embeddable.has_attribute?(key)
      authored_state[authored_state_properties[key]] = item.embeddable[key]
    end
  end

  return name, authored_state.to_json
end

def convert_open_response(item, library_interactive)
  name = item.embeddable.name != "Open Response" ? item.embeddable.name : ""
  authored_state = {
    version: 1,
    prompt: item.embeddable.prompt,
    defaultAnswer: item.embeddable.default_text,
    required: item.embeddable.is_prediction,
    questionType: "open_response",
    predictionFeedback: item.embeddable.give_prediction_feedback ? item.embeddable.prediction_feedback : undefined,
    hint: item.embeddable.hint
  }

  return name, authored_state.to_json
end

def convert_image(item, library_interactive)
  authored_state = {
    version: 1,
    url: item.embeddable.url,
    caption: item.embeddable.caption,
    credit: item.embeddable.credit,
    creditLink: item.embeddable.credit_url,
    creditLinkDisplayText: "",
    allowLightbox: true,
    scaling: "fitWidth"
  };

  return authored_state.to_json
end

def convert_image_question(item, library_interactive)
  name = item.embeddable.name != "Image Question" ? item.embeddable.name : ""
  background_source = item.embeddable.bg_source == "Shutterbug" ? "snapshot" : item.embeddable.bg_source === "Upload" ? "upload" : undefined
  linked_page_item = background_source == "snapshot" ? PageItem.where(:embeddable_id => item.embeddable.interactive_id, :embeddable_type => item.embeddable.interactive_type).first : nil
  new_linked_page_item = LinkedPageItem.new(primary_id: item.id, secondary_id: linked_page_item.id, label: "snapshotTarget")
  new_linked_page_item.save!

  # This is temporary while we're testing this out and creating new page items.
  # For the final version, we won't be creating new page items at this point. 
  # new_page_item = PageItem.new(position: item.position, section: item.section, interactive_page: item.interactive_page)
  # new_page_item.save!
  # if linked_page_item
  #   new_linked_page_item = LinkedPageItem.new(primary_id: new_page_item.id, secondary_id: linked_page_item.id, label: "snapshotTarget")
  #   new_linked_page_item.save!
  # end

  authored_state = {
    version: 1,
    questionType: "image_question",
    required: item.embeddable.is_prediction,
    predictionFeedback: item.embeddable.prediction_feedback,
    backgroundImageUrl: item.embeddable.bg_url,
    backgroundSource: background_source,
    imageFit: "shrinkBackgroundToCanvas",
    imagePosition: "center",
    answerPrompt: item.embeddable.drawing_prompt,
    prompt: item.embeddable.prompt,
    hint: item.embeddable.hint
  }

  return name, authored_state.to_json
end

def convert_video_player(item, library_interactive)
  # get the MP4 version if present, otherwise take the first URL in the source array
  video_source = ""
  item.embeddable.sources.each do |source|
    if source.format == "video/mp4"
      video_source = source.url
    end
  end
  if video_source == ""
    video_source = item.embeddable.sources[0].url
  end

  authored_state = {
    version: 1,
    questionType: "iframe_interactive",
    videoUrl: video_source,
    caption: item.embeddable.caption,
    credit: item.embeddable.credit,
    creditLinkDisplayText: "",
    fixedAspectRatio: "",
    poster: item.embeddable.poster_url
  }

  return authored_state.to_json
end

def new_properties(item, library_interactive)
  new_properties = {
    library_interactive_id: library_interactive.id,
    url_fragment: nil,
    inherit_aspect_ratio_method:	true,
    custom_aspect_ratio_method: nil,
    inherit_native_width: true,
    custom_native_width: library_interactive.native_width,
    inherit_native_height: true,
    custom_native_height: library_interactive.native_height,
    inherit_click_to_play: true,
    custom_click_to_play: false,
    inherit_full_window: true,
    custom_full_window: false,
    inherit_click_to_play_prompt: true,
    custom_click_to_play_prompt: nil,
    inherit_image_url: true,
    custom_image_url: nil
  }

  return new_properties
end

def save_new_item(item, legacy_ref_id, name, authored_state, new_properties)
  new_embeddable = ManagedInteractive.new(
    name: name,
    authored_state: authored_state,
    legacy_ref_id: legacy_ref_id
  )
  new_properties.each do |key, value|
    new_embeddable[key] = value
  end
  new_embeddable.save!
  # We probably DON'T want to create a new page item for the real migration. This is just for testing.
  # new_page_item = PageItem.new(position: item.position, section: item.section, interactive_page: item.interactive_page)
  # new_page_item.embeddable = new_embeddable
  # new_page_item.save!
end

def convert()
  # Get a list of official Library Interactives so we know which ones to convert to.
  library_interactives = {}
  LibraryInteractive.where(:official => true).each do |library_interactive|
    @convertable_embeddable_types.each do |question_type|
      if library_interactive.name == question_type
        library_interactives[question_type] = library_interactive
      end
    end
  end

  if library_interactives.length == 0
    raise Exception.new "No official library interactives found."
  end

  # activities_to_update = LightweightActivity.where(:runtime => "LARA")
  activities_to_update = LightweightActivity.where(:id => 62)
  activities_to_update.each do |activity|
    activity.pages.each do |page|
      # Make a new ManagedInteractive version of each instance of the specified built-in
      # embeddables and set the ManagedInteracative's legacy_ref_id to be the ref_id of the 
      # old, built-in embeddable. For now, the new ManagedInteractive embeddable will not 
      # be associated with the activity/page. That will be done by a different function.
      page.page_items.each do |item|
        if item.embeddable # not sure what page items don't have embeddables - plugins?
          legacy_ref_id = (LaraSerializationHelper.new).key(item.embeddable)
          case item.embeddable_type
            when "Embeddable::Answer", "Embeddable::AnswerFinder", "Embeddable::FeedbackFunctionality", "Embeddable::FeedbackItem", "Embeddable::LabbookAnswer", "Embeddable::Labbook"
              activity.defunct = true
              activity.save!
              return
            when "Embeddable::MultipleChoice"
              library_interactive = library_interactives["Multiple Choice"]
              name, authored_state = convert_multiple_choice(item, library_interactive)
              new_properties = new_properties(item, library_interactive)
              save_new_item(item, legacy_ref_id, name, authored_state, new_properties)
            when "Embeddable::OpenResponse"
              library_interactive = library_interactives["Open Response"]
              name, authored_state = convert_open_response(item, library_interactive)
              new_properties = new_properties(item, library_interactive)
              save_new_item(item, legacy_ref_id, name, authored_state, new_properties)
            when "ImageInteractive"
              library_interactive = library_interactives["Image Interactive"]
              authored_state = convert_image(item, library_interactive)
              new_properties = new_properties(item, library_interactive)
              save_new_item(item, legacy_ref_id, name, authored_state, new_properties)
            when "VideoInteractive"
              library_interactive = library_interactives["Video Player"]
              authored_state = convert_video_player(item, library_interactive)
              new_properties = new_properties(item, library_interactive)
              save_new_item(item, legacy_ref_id, name, authored_state, new_properties)
            when "Embeddable::ImageQuestion"
              library_interactive = library_interactives["Image Question"]
              name, authored_state = convert_image_question(item, library_interactive)
              new_properties = new_properties(item, library_interactive)
              save_new_item(item, legacy_ref_id, name, authored_state, new_properties)
            else
              return
            end
          end
        end
      end
    end
end

def delete_new_orphaned_embeddables()
  # Delete any ManagedInteractive embeddables that have a legacy_ref_id value
  # but are not associated with a PageItem.
  ManagedInteractive.where("legacy_ref_id IS NOT NULL AND legacy_ref_id != ?", "").each do |mi|
    if PageItem.where(:embeddable_id => mi.id, :embeddable_type => "ManagedInteractive").count == 0
      puts "Deleting orphaned ManagedInteractive: #{mi.id}"
      mi.destroy
    end
  end
  # TODO: Delete any LinkedPageItems associated with the deleted ManagedInteractive embeddables.
end

def delete_old_embeddables()
  # TODO: Delete all built-in embeddables that are not associated with a PageItem.

end

def replace_old_embeddables()
  # Hook up any ManagedInteractive embeddables that have a legacy_ref_id value and are not 
  # associated with a PageItem. Using the ManagedInteractive embeddable's legacy_ref_id,
  # find the built-in embeddable and PageItem that it is associated with. Then, replace the 
  # PageItem's built-in embeddable with the ManagedInteractive embeddable. (Delete the old, 
  # built-in embeddable?) We will also need to add LinkedPageItems to
  ManagedInteractive.where("legacy_ref_id IS NOT NULL AND legacy_ref_id != ?", "").each do |mi|
    if PageItem.where(:embeddable_id => mi.id, :embeddable_type => "ManagedInteractive").count == 0
      old_embeddable_id, old_embeddable_type = mi.legacy_ref_id.split("-")
      page_item = PageItem.where(:embeddable_id => old_embeddable_id, :embeddable_type => old_embeddable_type).first
      if page_item
        puts "page_item: #{page_item.inspect}"
        # TODO: Update the page item's embeddable to be the ManagedInteractive embeddable.
      end
    end
  end
  # TODO: Make sure TE question wrappers are updated to point at new ManagedInteractive.

end

namespace :convert_embeddables do

  desc "Counts the number of embeddables to be converted."
  task :count_embeddables => :environment do
    count_embeddables
  end

  desc "Create new ManagedInteractive versions of built-in embeddables."
  task :convert => :environment do
    convert
  end

  desc "Deletes ManagedInteractive copies of built-in embeddables that are not associated with a PageItem."
  task :delete_new_orphaned_embeddables => :environment do
    delete_new_orphaned_embeddables
  end

  desc "Replace each built-in embeddable reference to its associated ManagedInteractive version in each PageItem."
  task :replace_old_embeddables => :environment do
    replace_old_embeddables
  end

end 