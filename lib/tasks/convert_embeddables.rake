
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

def count_embeddables()
  # Get a count of all built-in embeddables that need to be converted.
  embeddables_count = PageItem.where(:embeddable_type => @convertable_embeddable_classes).length
  puts "There are #{embeddables_count} built-in embeddables to convert."
end

def multiple_choice_authored_state(item)
  
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

  return authored_state.to_json
end

def open_response_authored_state(item)
  authored_state = {
    version: 1,
    prompt: item.embeddable.prompt,
    defaultAnswer: item.embeddable.default_text,
    required: item.embeddable.is_prediction,
    questionType: "open_response",
    predictionFeedback: item.embeddable.give_prediction_feedback,
    hint: item.embeddable.hint
  }

  return authored_state.to_json
end

def image_authored_state(item)
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

def image_question_authored_state(item)
  background_source = item.embeddable.bg_source == "Shutterbug" ? "snapshot" : item.embeddable.bg_source === "Upload" ? "upload" : nil
  target_page_item = background_source == "snapshot" ? PageItem.where(:embeddable_id => item.embeddable.interactive_id, :embeddable_type => item.embeddable.interactive_type).first : nil
  if target_page_item
    new_linked_page_item = LinkedPageItem.new(primary_id: item.id, secondary_id: target_page_item.id, label: "snapshotTarget")
    new_linked_page_item.save!
  end

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

  return authored_state.to_json
end

def video_player_authored_state(item)
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

def save_new_item(params)
  new_embeddable = ManagedInteractive.new(
    name: params[:name],
    authored_state: params[:authored_state],
    legacy_ref_id: params[:legacy_ref_id],
    url_fragment: nil,
    inherit_aspect_ratio_method:	true,
    custom_aspect_ratio_method: nil,
    inherit_native_width: true,
    inherit_native_height: true,
    inherit_click_to_play: true,
    custom_click_to_play: false,
    inherit_full_window: true,
    custom_full_window: false,
    inherit_click_to_play_prompt: true,
    custom_click_to_play_prompt: nil,
    inherit_image_url: true,
    custom_image_url: nil
  )
  new_embeddable.library_interactive = params[:library_interactive]
  new_embeddable.save!
end

def create_new_embeddables()
  # Get a list of official Library Interactives so we know which ones to convert to.
  library_interactives = {}
  LibraryInteractive.where(:official => true).each do |library_interactive|
    @convertable_embeddable_types.each do |question_type|
      if library_interactive.name == question_type
        library_interactives[question_type] = library_interactive
      end
    end
  end

  if library_interactives.length < 5
    missing_official_interactives = @convertable_embeddable_types - library_interactives.keys
    raise Exception.new "Error: Missing official library interactives. Before trying again, please mark an instance of the following library interactives as official: #{missing_official_interactives.join(", ")}"
  end

  activities_to_update = LightweightActivity.where(:runtime => "LARA")
  activities_to_update.each do |activity|
    activity.pages.each do |page|
      # Make a new ManagedInteractive version of each instance of the specified built-in
      # embeddables. Set the new ManagedInteracative's legacy_ref_id to be the ref_id of the 
      # built-in embeddable.
      page.page_items.each do |item|
        library_interactive = nil
        authored_state = nil
        if item.embeddable
          legacy_ref_id = (LaraSerializationHelper.new).key(item.embeddable)

          case item.embeddable_type
          when "Embeddable::Answer", "Embeddable::AnswerFinder", "Embeddable::FeedbackFunctionality", "Embeddable::FeedbackItem", "Embeddable::LabbookAnswer", "Embeddable::Labbook"
            activity.defunct = true
            activity.save!
          when "Embeddable::MultipleChoice"
            library_interactive = library_interactives["Multiple Choice"]
            name = item.embeddable.name != "Multiple Choice Question element" ? item.embeddable.name : ""
            authored_state = multiple_choice_authored_state(item)
          when "Embeddable::OpenResponse"
            library_interactive = library_interactives["Open Response"]
            name = item.embeddable.name != "Open Response" ? item.embeddable.name : ""
            authored_state = open_response_authored_state(item)
          when "ImageInteractive"
            library_interactive = library_interactives["Image Interactive"]
            authored_state = image_authored_state(item)
          when "VideoInteractive"
            library_interactive = library_interactives["Video Player"]
            authored_state = video_player_authored_state(item)
          when "Embeddable::ImageQuestion"
            library_interactive = library_interactives["Image Question"]
            name = item.embeddable.name != "Image Question" ? item.embeddable.name : ""
            authored_state, new_page_item = image_question_authored_state(item)
          end

          if library_interactive && authored_state
            save_new_item({
              :item => item,
              :legacy_ref_id => legacy_ref_id,
              :name => name,
              :authored_state => authored_state,
              :library_interactive => library_interactive
            })
          end
        end
      end
    end
  end
end

def delete_orphaned_new_embeddables()
  # Delete any ManagedInteractive embeddables that have a legacy_ref_id value but are not 
  # associated with a PageItem.
  deleted_embeddables = 0
  ManagedInteractive.where("legacy_ref_id IS NOT NULL AND legacy_ref_id != ?", "").each do |managed_interactive|
    if !managed_interactive.page_item
      puts "Deleting orphaned ManagedInteractive: #{managed_interactive.id}"
      managed_interactive.destroy
      deleted_embeddables += 1
      # Delete any LinkedPageItems associated with the deleted ManagedInteractive embeddables.
      old_embeddable_id, old_embeddable_type = managed_interactive.legacy_ref_id.split("-")
      old_embeddable_class = old_embeddable_type.constantize
      old_embeddable = old_embeddable_class.find(old_embeddable_id)
      if old_embeddable.respond_to?(:page_items)
        old_embeddable.page_items.each do |page_item|
          LinkedPageItem.where(:primary_id => page_item.id).destroy_all
        end
      else
        LinkedPageItem.where(:primary_id => old_embeddable.page_item.id).destroy_all
      end
    end
  end
  puts "Deleted #{deleted_embeddables} orphaned ManagedInteractives."
end

def delete_orphaned_old_embeddables()
  # Delete all built-in embeddables that are not associated with a PageItem.
  deleted_embeddables = 0
  @convertable_embeddable_classes.each do |embeddable_class|
    embeddable_class.constantize.all do |embeddable|
      if embeddable.page_items.count == 0
        puts "Deleting orphaned built-in embeddable: #{embeddable.id}"
        embeddable.destroy
        deleted_embeddables += 1
      end
    end
  end
  puts "Deleted #{deleted_embeddables} orphaned old embeddables."
end

def replace_old_embeddables()
  # To replace the old, built-in embeddables, first we find any ManagedInteractive embeddables
  # that have a legacy_ref_id value and are not yet associated with a PageItem. Then, we use 
  # each of these ManagedInteractive embeddables' legacy_ref_id to find the old embeddable it 
  # will replace and the PageItem that it's associated with. We replace the PageItem's old 
  # embeddable with the new embeddable. We also update any wrapping plugins for the old embeddable
  # so they point to the new embeddable. Finally, delete the old embeddable.
  new_embeddables = ManagedInteractive.where("legacy_ref_id IS NOT NULL AND legacy_ref_id != ?", "")
  new_embeddables.each do |new_embeddable|
    if PageItem.where(:embeddable_id => new_embeddable.id, :embeddable_type => "ManagedInteractive").count == 0
      old_embeddable_id, old_embeddable_type = new_embeddable.legacy_ref_id.split("-")
      old_embeddable = old_embeddable_type.constantize.find(old_embeddable_id)
      page_items = PageItem.where(:embeddable_id => old_embeddable.id, :embeddable_type => old_embeddable_type)
      page_items.each do |page_item|
        page_item.embeddable = new_embeddable
        page_item.save!
        wrapping_plugins = Embeddable::EmbeddablePlugin.where(:embeddable_id => old_embeddable.id, :embeddable_type => old_embeddable_type)
        wrapping_plugins.each do |wrapping_plugin|
          wrapping_plugin.embeddable = new_embeddable
          wrapping_plugin.save!
        end
        old_embeddable.destroy
      end
    end
  end
  # TODO: Set associated activities' runtime to "Activity Player" after all old embeddables are replaced?
end

namespace :convert_embeddables do

  desc "Counts the number of embeddables to be converted."
  task :count_embeddables => :environment do
    count_embeddables
  end

  desc "Creates new ManagedInteractive versions of built-in embeddables."
  task :create_new_embeddables => :environment do
    create_new_embeddables
  end

  desc "Deletes any ManagedInteractive embeddables that are not associated with a PageItem."
  task :delete_orphaned_new_embeddables => :environment do
    delete_orphaned_new_embeddables
  end

  desc "Replaces each built-in embeddable reference with its associated ManagedInteractive version in each PageItem."
  task :replace_old_embeddables => :environment do
    replace_old_embeddables
  end

  desc "Deletes amy built-in embeddables that are not associated with a PageItem."
  task :delete_orphaned_old_embeddables => :environment do
    delete_orphaned_old_embeddables
  end

end 