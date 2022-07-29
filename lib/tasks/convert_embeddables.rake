
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

def count_embeddables(type=nil)
  types = type ? type : @convertable_embeddable_classes
  embeddables_count = PageItem.where(:embeddable_type => types).length
  puts "There #{embeddables_count == 1 ? "is" : "are"} #{embeddables_count} #{type ? type : "built-in"} embeddables to convert."
end

def multiple_choice_authored_state(item)
  converted_choices = []
  item.embeddable.choices.each do |choice|
    converted_choice = {
      id: choice.id.to_s, # to be consistent with Question Interactives MC data format
      content: choice.choice,
      correct: choice.is_correct,
      choiceFeedback: choice.prompt
    }
    converted_choices.push(converted_choice)
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
  background_source =
    if item.embeddable.bg_source == "Shutterbug"
      "snapshot"
    elsif item.embeddable.bg_source === "Upload"
      "upload"
    elsif item.embeddable.bg_url.present? # && item.embeddable.bg_source == "Drawing", but it's redundant at this point
      "url"
    else
      nil
    end

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
    imageFit: "shrinkBackgroundToCanvas",
    imagePosition: "center",
    answerPrompt: item.embeddable.drawing_prompt,
    prompt: item.embeddable.prompt,
    hint: item.embeddable.hint
  }
  # Question Interactives Image Questions authoring complains about `null` or "" (empty string) values.
  # So, if backgroundSource should not be defined if it's equal to `nil`.
  if background_source.present?
    authored_state[:backgroundSource] = background_source
  end

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
  if video_source == "" && item.embeddable.sources.length > 0
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
    legacy_ref_type: params[:legacy_ref_type],
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

def create_new_embeddables(activity_id=nil)
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

  serialization_helper = LaraSerializationHelper.new
  where_conditions = activity_id ? {id: activity_id} : {runtime: "LARA"}
  activities_to_update = LightweightActivity.includes(pages: {page_items: [:embeddable]}).where(where_conditions)
  activities_to_process = activities_to_update.count
  activities_processed = 0
  embeddables_processed = 0
  activities_to_update.find_each(batch_size: 10) do |activity|
    activity.pages.each do |page|
      page.page_items.each do |page_item|
        library_interactive = nil
        authored_state = nil
        if page_item.embeddable
          legacy_ref_id, legacy_ref_type = serialization_helper.key(page_item.embeddable).split("-")
          # The following check to see if a new managed interactive has already been created
          # would be very slow, so we're disabling it for now. We should enable it when we
          # run this task a second time to determine if we need to create a new managed
          # interactive embeddable. We will have to create a new one if there are brand new
          # built-in embeddables that weren't processed in the first pass, or if an
          # existing built-in embeddable was modified after the first pass.
          # TODO: Check the updated_at timestamps to see if an existing built-in embeddable
          # has been modified after the first pass.
          # existing_managed_interactive = ManagedInteractive.where(legacy_ref_id: legacy_ref_id).includes(:page_items).where(page_items: { id: nil })
          # if existing_managed_interactive
          #   return
          # end

          case page_item.embeddable_type
          when "Embeddable::Answer", "Embeddable::AnswerFinder", "Embeddable::FeedbackFunctionality", "Embeddable::FeedbackItem", "Embeddable::LabbookAnswer", "Embeddable::Labbook"
            activity.defunct = true
            activity.save(:validate => false)
          when "Embeddable::MultipleChoice"
            library_interactive = library_interactives["Multiple Choice"]
            name = page_item.embeddable.name != "Multiple Choice Question element" ? page_item.embeddable.name : ""
            authored_state = multiple_choice_authored_state(page_item)
          when "Embeddable::OpenResponse"
            library_interactive = library_interactives["Open Response"]
            name = page_item.embeddable.name != "Open Response" ? page_item.embeddable.name : ""
            authored_state = open_response_authored_state(page_item)
          when "ImageInteractive"
            library_interactive = library_interactives["Image Interactive"]
            authored_state = image_authored_state(page_item)
          when "VideoInteractive"
            library_interactive = library_interactives["Video Player"]
            authored_state = video_player_authored_state(page_item)
          when "Embeddable::ImageQuestion"
            library_interactive = library_interactives["Image Question"]
            name = page_item.embeddable.name != "Image Question" ? page_item.embeddable.name : ""
            authored_state = image_question_authored_state(page_item)
          end

          if library_interactive && authored_state
            save_new_item({
              legacy_ref_id: legacy_ref_id,
              legacy_ref_type: legacy_ref_type,
              name: name,
              authored_state: authored_state,
              library_interactive: library_interactive
            })
            page_item.embeddable.migration_status = "in progress"
            page_item.embeddable.save!
            embeddables_processed += 1
            if embeddables_processed % 100 == 0
              puts "Processed #{embeddables_processed} embeddables."
            end
          end
        end
      end
    end
    activities_processed += 1
    if activities_processed % 100 == 0
      puts "Processed #{activities_processed} of #{activities_to_process} activities."
    end
    activity.migration_status = "in progress"
    activity.save(:validate => false)
  end
  puts "Processed #{activities_processed} of #{activities_to_process} activities."
end

def delete_orphaned_new_embeddables()
  orphaned_embeddables = ManagedInteractive.where("legacy_ref_id IS NOT NULL AND legacy_ref_id != ?", "").includes(:page_item).where(page_items: { id: nil })
  embeddables_to_delete = orphaned_embeddables.count
  embeddables_deleted = 0
  orphaned_embeddables.find_each(batch_size: 100) do |embeddable|
    embeddable.destroy
    # Delete any LinkedPageItems associated with the deleted ManagedInteractive embeddables.
    old_embeddable_type = embeddable.legacy_ref_type.constantize
    old_embeddable = old_embeddable_type.find(embeddable.legacy_ref_id)
    if old_embeddable.respond_to?(:page_items)
      old_embeddable.page_items.each do |page_item|
        LinkedPageItem.where(primary_id: page_item.id).destroy_all
      end
    else
      LinkedPageItem.where(primary_id: old_embeddable.page_item.id).destroy_all
    end
    embeddables_deleted += 1
    if embeddables_deleted % 100 == 0
      puts "Deleted #{embeddables_deleted} of #{embeddables_to_delete} orphaned ManagedInteractive embeddables."
    end
  end
  puts "Deleted #{embeddables_deleted} of #{embeddables_to_delete} orphaned ManagedInteractive embeddables."
end

def delete_orphaned_old_embeddables()
  @convertable_embeddable_classes.each do |embeddable_class|
    embeddable_type = embeddable_class.constantize
    if embeddable_type.method_defined?(:page_items)
      orphaned_embeddables = embeddable_type.includes(:page_items).where(page_items: { id: nil })
    else
      orphaned_embeddables = embeddable_type.includes(:page_item).where(page_items: { id: nil })
    end
    embeddables_to_delete = orphaned_embeddables.count
    embeddables_deleted = 0
    orphaned_embeddables.find_each(batch_size: 100) do |embeddable|
      embeddable.destroy
      embeddables_deleted += 1
      if embeddables_deleted % 100 == 0
        puts "Deleted #{embeddables_deleted} of #{embeddables_to_delete} orphaned  #{embeddable_class} embeddables."
      end
    end
    puts "Deleted #{embeddables_deleted} of #{embeddables_to_delete} orphaned #{embeddable_class} embeddables."
  end
end

def replace_old_embeddables(activity_id=nil)
  where_conditions = activity_id ? {id: activity_id} : {runtime: "LARA"}
  activities_to_update = LightweightActivity.preload(pages: {legacy_page_items: {embeddable: [:converted_interactive, :embeddable_plugins]}}).where(where_conditions)
  activities_to_process = activities_to_update.count
  activities_processed = 0
  activities_to_update.find_each(batch_size: 10) do |activity|
    activity.pages.each do |page|
      page.legacy_page_items.each do |page_item|
        old_embeddable = page_item.embeddable
        new_embeddable = page_item.embeddable.converted_interactive
        wrapping_plugins = page_item.embeddable.embeddable_plugins
        wrapping_plugins.each do |wrapping_plugin|
          wrapping_plugin.embeddable = new_embeddable
          wrapping_plugin.save!
        end
        page_item.embeddable = new_embeddable
        page_item.save!
      end
    end
    activities_processed += 1
    if activities_processed % 100 == 0
      puts "Processed #{activities_processed} of #{activities_to_process} activities."
    end
    activity.runtime = "Activity Player"
    activity.migration_status = "migrated"
    activity.save(:validate => false)
  end
  puts "Processed #{activities_processed} of #{activities_to_process} activities."
end

namespace :convert_embeddables do

  desc "Counts the number of embeddables to be converted."
  task :count_embeddables, [:type] => :environment do |task, args|
    count_embeddables(args[:type])
  end

  desc "Creates new ManagedInteractive versions of built-in embeddables."
  task :create_new_embeddables, [:activity] => :environment do |task, args|
    create_new_embeddables(args[:activity])
  end

  desc "Deletes any ManagedInteractive embeddables that are not associated with a PageItem."
  task :delete_orphaned_new_embeddables => :environment do
    delete_orphaned_new_embeddables
  end

  desc "Replaces each built-in embeddable reference with its associated ManagedInteractive version in each PageItem."
  task :replace_old_embeddables, [:activity] => :environment do |task, args|
    replace_old_embeddables(args[:activity])
  end

  desc "Deletes amy built-in embeddables that are not associated with a PageItem."
  task :delete_orphaned_old_embeddables => :environment do
    delete_orphaned_old_embeddables
  end

end
