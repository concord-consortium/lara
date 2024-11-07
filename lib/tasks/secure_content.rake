def get_columns_with_text_content(model_class)
  columns = []
  model_class.columns_hash.each do |key,value|
    columns << key unless [:string, :text].index(value.type).nil? 
  end
  columns
end


def fix_insecure(content, fix)
  if content.nil? 
    return
  end
  content.gsub(fix[:original_url],fix[:replace_url])
end

def log_insecure_content(item,item_columns,log_string)
  
  insecure_content_log = ""  
  item_columns.each do |column_name|
    content = item[column_name] || ""
    insecure_content = URI.extract(content, ['http'])
    unless(insecure_content.length == 0)
      @insecure_content_count += insecure_content.length
      insecure_content_log << " #{column_name}:#{insecure_content} "
    end
  end
  
  unless insecure_content_log == "" 
    log_string << "#{insecure_content_log}"
    rake_logger.info("following insecure content is found in this item:#{log_string}")  
  end
end

def fix_item(item,item_columns,to_fix,log_string)
  unless to_fix.nil?
    
    updates = {}
    
    item_columns.each do |column_name|
      new_value = fix_insecure(item[column_name], to_fix)
      unless item[column_name] == new_value
        updates[column_name] = new_value
        @insecure_content_count += 1
      end
    end
    item.attributes = updates
    if item.save(validate: false)
      unless updates.length == 0
        log_string << " updating attributes #{updates}."
        rake_logger.info(log_string)
      end
    else
      log_string << " Could not update attributes #{updates}."
      rake_logger.info(log_string)
    end
    
  end
end

def scan_interactive(interactive, to_fix, log_string)
  case interactive
  when VideoInteractive
    log_string << "::VideoInteractive:#{interactive.id}" 
    if to_fix.nil?
      log_insecure_content(interactive, @video_interactive_columns, log_string.clone)
    else
      fix_item(interactive, @video_interactive_columns, to_fix, log_string.clone)
    end
    interactive.sources.each do |source|
      sources_log = log_string.clone << "::VideoSource:#{source.id}"
      if to_fix.nil?
        log_insecure_content(source, @video_source_columns, sources_log.clone)
      else
        fix_item(source, @video_source_columns, to_fix, sources_log.clone)
      end
    end 
  when ImageInteractive
    log_string << "::ImageInteractive:#{interactive.id}" 
    if to_fix.nil?
      log_insecure_content(interactive, @image_interactive_columns, log_string.clone)
    else
      fix_item(interactive, @image_interactive_columns, to_fix, log_string.clone)
    end
  when MwInteractive 
    log_string << "::MwInteractive:#{interactive.id}" 
    if to_fix.nil?
      log_insecure_content(interactive, @mw_interactive_columns, log_string.clone)
    else
      fix_item(interactive, @mw_interactive_columns, to_fix, log_string.clone)
    end
  end
end

def scan_embeddable(embeddable, to_fix, log_string)
  
  @imagequestion_embedable_columns = get_columns_with_text_content(Embeddable::ImageQuestion)
  @multiplechoice_embedable_columns = get_columns_with_text_content(Embeddable::MultipleChoice)
  @multiplechoicechoice_embedable_columns = get_columns_with_text_content(Embeddable::MultipleChoiceChoice)
  @openresponse_embedable_columns = get_columns_with_text_content(Embeddable::OpenResponse)
  @xhtml_embedable_columns = get_columns_with_text_content(Embeddable::Xhtml)
  
  case embeddable
  when Embeddable::ImageQuestion
    
    log_string << "::Embeddable::ImageQuestion:#{embeddable.id}" 
    if to_fix.nil?
      log_insecure_content(embeddable, @imagequestion_embedable_columns, log_string.clone)
    else
      fix_item(embeddable, @imagequestion_embedable_columns, to_fix, log_string.clone)
    end
    
  when Embeddable::MultipleChoice
    
    log_string << "::Embeddable::MultipleChoice:#{embeddable.id}" 
    if to_fix.nil?
      log_insecure_content(embeddable, @multiplechoice_embedable_columns, log_string.clone)
    else
      fix_item(embeddable, @multiplechoice_embedable_columns, to_fix, log_string.clone)
    end
    embeddable.choices.each do |choice|
      choices_log = log_string.clone << "::Embeddable::MultipleChoiceChoice:#{choice.id}"
      if to_fix.nil?
        log_insecure_content(choice, @multiplechoicechoice_embedable_columns, choices_log.clone)
      else
        fix_item(choice, @multiplechoicechoice_embedable_columns, to_fix, choices_log.clone)
      end
      
    end
     
  when Embeddable::OpenResponse
    
    log_string << "::Embeddable::OpenResponse:#{embeddable.id}" 
    if to_fix.nil?
      log_insecure_content(embeddable, @openresponse_embedable_columns, log_string.clone)
    else
      fix_item(embeddable, @openresponse_embedable_columns, to_fix, log_string.clone)
    end
    
  when Embeddable::Xhtml
    
    log_string << "::Embeddable::Xhtml:#{embeddable.id}" 
    
    if to_fix.nil?
      log_insecure_content(embeddable, @xhtml_embedable_columns, log_string.clone)
    else
      fix_item(embeddable, @xhtml_embedable_columns, to_fix, log_string.clone)
    end
    
  end
end

def scan_page(page, to_fix, log_string)
  
  log_string << "::InteractivePage:#{page.id}"
  
  if to_fix.nil?
    log_insecure_content(page, @page_columns, log_string.clone)
  else
    fix_item(page, @page_columns, to_fix, log_string.clone)
  end
  page.interactives.each do |interactive|
    scan_interactive(interactive, to_fix, log_string.clone)
  end
  
  page.embeddables.each do |embeddable|
    scan_embeddable(embeddable, to_fix, log_string.clone)
  end
  
end

def scan_activity(record_id, to_fix, log_string)
  
  log_string << "::LightweightActivity:#{record_id}"
  
  record_activity = LightweightActivity.find(record_id)
  
  if to_fix.nil?
    log_insecure_content(record_activity, @activity_columns, log_string.clone)
  else
    fix_item(record_activity, @activity_columns, to_fix, log_string.clone)
  end
  
  record_activity.pages.each do |page|
    scan_page(page, to_fix , log_string.clone)
  end
  
end

def scan_sequence(record_id, to_fix, log_string)
  
  log_string << "::Sequence:#{record_id}"
  
  record_sequence = Sequence.find(record_id)
  if to_fix.nil?
    log_insecure_content(record_sequence, @sequence_columns, log_string.clone)
  else
    fix_item(record_sequence, @sequence_columns, to_fix, log_string.clone)
  end
  record_sequence.lightweight_activities.each do |activity|
    scan_activity(activity.id, to_fix , log_string.clone)
  end
  
end

def prepare_columns 
  @sequence_columns = get_columns_with_text_content(Sequence)
  @activity_columns = get_columns_with_text_content(LightweightActivity)
  @page_columns = get_columns_with_text_content(InteractivePage)
  @image_interactive_columns = get_columns_with_text_content(ImageInteractive)
  @video_interactive_columns = get_columns_with_text_content(VideoInteractive)
  @video_source_columns = get_columns_with_text_content(VideoSource)
  @mw_interactive_columns = get_columns_with_text_content(MwInteractive)
  @imagequestion_embedable_columns = get_columns_with_text_content(Embeddable::ImageQuestion)
  @multiplechoice_embedable_columns = get_columns_with_text_content(Embeddable::MultipleChoice)
  @multiplechoicechoice_embedable_columns = get_columns_with_text_content(Embeddable::MultipleChoiceChoice)
  @openresponse_embedable_columns = get_columns_with_text_content(Embeddable::OpenResponse)
  @xhtml_embedable_columns = get_columns_with_text_content(Embeddable::Xhtml)
end

def rake_logger
  @@my_logger ||= Logger.new("#{Rails.root}/log/secure_content.log")
end

def initialize_scan
  @insecure_content_count = 0
  rake_logger.info("\n\n lOG CREATED AT #{Time.now} \n\n")
  prepare_columns
end

def is_provider_https?(run)
  unless run.remote_endpoint.blank?
    a_uri = URI.parse(run.remote_endpoint)
    auth_url = (a_uri.port == 80) ? "#{a_uri.host}" : "#{a_uri.host}:#{a_uri.port}"
    ENV['CONCORD_CONFIGURED_PORTALS'].split.each do |cp|
      c_uri = URI.parse(ENV["CONCORD_#{cp}_URL"])
      configured_uri = (c_uri.port == 80) ? "#{c_uri.host}" : "#{c_uri.host}:#{c_uri.port}"
      if configured_uri == auth_url
        if c_uri.scheme == "https"
          return true
        end
      end
    end
  end
  return false
end

def scan_learner_data(to_update, log_string)
  insecure_content_count = 0
  to_fix = {original_url: "http://",replace_url: "https://"}
  Run.all.each do |runs|
    if is_provider_https?(runs) 
      if runs[:remote_endpoint] && (runs[:remote_endpoint].include? "http://")
        insecure_content_count += 1
        if to_update
          runs[:remote_endpoint] = fix_insecure(runs[:remote_endpoint],to_fix)
          if runs.save(validate: false)
            log_string << "\nRuns #{runs[:id]} :: remote_endpoint : #{runs[:remote_endpoint]}"
          else
            log_string << "\nFailed to update Runs #{runs[:id]}"
          end          
        else
          log_string << "\nRuns #{runs[:id]} :: remote_endpoint : #{runs[:remote_endpoint]}"
        end  
      end
    end
  end
    
  InteractiveRunState.all.each do |interactive_run_state|
    run = interactive_run_state.run
    if run && is_provider_https?(run)
      if interactive_run_state[:learner_url] && (interactive_run_state[:learner_url].include? "http://")
        insecure_content_count += 1
        if to_update
          interactive_run_state[:learner_url] = fix_insecure(interactive_run_state[:learner_url],to_fix)
          if interactive_run_state.save(validate: false)
            log_string << "\nInteractiveRunState #{interactive_run_state[:id]} :: learner_url : #{interactive_run_state[:learner_url]}"
          else
            log_string << "\n Failed to update InteractiveRunState #{interactive_run_state[:id]}"
          end
        else
          log_string << "\nInteractiveRunState #{interactive_run_state[:id]} :: learner_url : #{interactive_run_state[:learner_url]}"
        end
      end
  
      if interactive_run_state[:raw_data]
        raw_data = JSON.parse(interactive_run_state[:raw_data])
        lara_options = raw_data["lara_options"]
        unless lara_options.nil?
          if lara_options["reporting_url"] && (lara_options["reporting_url"].include? "http://")
            insecure_content_count += 1
            if to_update
              lara_options["reporting_url"] = fix_insecure(lara_options["reporting_url"],to_fix)
              interactive_run_state[:raw_data] = raw_data
              if interactive_run_state.save(validate: false)
                log_string << "\nInteractiveRunState #{interactive_run_state[:id]} :: reporting_url : #{lara_options["reporting_url"]}"
              else
                log_string << "\n Failed to update InteractiveRunState #{interactive_run_state[:id]}"
              end
            else
              log_string << "\nInteractiveRunState #{interactive_run_state[:id]} :: reporting_url : #{lara_options["reporting_url"]}"
            end
          end
        end
      end
    end
  end
  if to_update
    if insecure_content_count > 0
      log_string << "\n\n#{insecure_content_count} records updated."
    else
      log_string << "\n\nNo records updated."
    end
  else
    if insecure_content_count > 0
      log_string << "\nInsecure content in #{insecure_content_count} records."
    else
      log_string << "\nNo insecure records found."
      p "No insecure records found."
    end
  end
  rake_logger.info("#{log_string}")
  p "Rake run successfully.Please view secure_content.log file for details."
end

namespace :secure_content do
  require "uri"
  require 'highline/import'
  
  desc "Scan activity for insecure content"
  task get_insecure_content_activity: :environment do 
    
    initialize_scan
      
    record_ids = ask("Enter ActivieRecord ids: ") { |s| s.default = "all" }
    
    if record_ids == "all"
      LightweightActivity.all.each do |activity|
        scan_activity(activity.id,nil,"")
      end
    else
      record_ids = record_ids.split(",")
      record_ids.each do |record_id|
        scan_activity(record_id,nil,"")
      end
    end
    
    if @insecure_content_count == 0
      rake_logger.info("No insecure urls found")
      p "No insecure urls found"
    else
      rake_logger.info("Total number of fixes: #{@insecure_content_count}")
      p "Total number of insecure content: #{@insecure_content_count}. View log/secure_content.log file for more Details."
    end
    
  end
  
  desc "Scan sequence for insecure content"
  task get_insecure_content_sequence: :environment do 
    
    initialize_scan
    
    record_ids = ask("Enter ActivieRecord ids: ") { |s| s.default = "all" }
    
    if record_ids == "all"
      Sequence.all.each do |activity|
        scan_sequence(activity.id, nil, "")
      end
    else
      record_ids = record_ids.split(",")
      record_ids.each do |record_id|
        scan_sequence(record_id, nil, "")
      end
    end
    
    if @insecure_content_count == 0
      rake_logger.info("No insecure urls found")
      p "No insecure urls found"
    else
      rake_logger.info("Total number of fixes: #{@insecure_content_count}")
      p "Total number of insecure content: #{@insecure_content_count}. View log/secure_content.log file for more Details."
    end
    
  end
  
  desc "Scan learner data for insecure content"
  task get_insecure_learner_data: :environment do
    scan_learner_data(false, "\n\nInsecure learner_data is found in the following items.\n")
  end
  
  desc "Fix learner data for insecure content"
  task fix_insecure_learner_data: :environment do
    scan_learner_data(true,  "\n\nFixed Insecure learner_data for following items.\n")
  end
  
  desc "Fix insecure content of activity"
  task fix_insecure_content_activity: :environment do 
    
    initialize_scan
    
    record_ids = ask("Enter ActivieRecord ids: ") { |s| s.default = "all" }
    original_url = ask("Enter the insecure url: ") { |s| s.default = "http://" }
    replace_url = ask("Enter the secure url: ") { |s| s.default = "https://" }
   
    
    if record_ids == "all"
      LightweightActivity.all.each do |activity|
        scan_activity(activity.id,{ 
          original_url: original_url,
          replace_url: replace_url
        },"")
      end
    else
      record_ids = record_ids.split(",")
      record_ids.each do |record_id|
        scan_activity(record_id,{ 
          original_url: original_url,
          replace_url: replace_url
        },"")
      end
    end
    
    if @insecure_content_count == 0
      rake_logger.info("No insecure urls found")
      p "No insecure urls found"
    else
      rake_logger.info("Total number of fixes: #{@insecure_content_count}")
      p "Total number of fixes: #{@insecure_content_count}. View log/secure_content.log file for more Details."
    end
         
  end
  
  desc "Fix insecure content of sequence"
  task fix_insecure_content_sequence: :environment do 
    
    initialize_scan
    
    record_ids = ask("Enter ActivieRecord ids: ") { |s| s.default = "all" }
    original_url = ask("Enter the insecure url: ") { |s| s.default = "http://" }
    replace_url = ask("Enter the secure url: ") { |s| s.default = "https://" }
    
    
    if record_ids == "all"
      Sequence.all.each do |sequence|
        scan_sequence(sequence.id,{ 
          original_url: original_url,
          replace_url: replace_url
        },"")
      end
    else
      record_ids = record_ids.split(",")
      record_ids.each do |record_id|
        scan_sequence(record_id,{ 
          original_url: original_url,
          replace_url: replace_url
        },"")
      end
    end
    
    if @insecure_content_count == 0
      rake_logger.info("No insecure urls found")
      p "No insecure urls found"
    else
      rake_logger.info("Total number of fixes: #{@insecure_content_count}")
      p "Total number of fixes: #{@insecure_content_count}. View log/secure_content.log file for more Details."
    end
             
  end

end
