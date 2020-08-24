# This script will print CSV string describing all the activities that include selected embeddable type.
# It's meant to be run by developer in rails console directly (can be copy-pasted to staging or production console).
# It iterates over activities instead of the embeddable models as e.g. on LARA staging there are 300k Labbooks,
# but only 13k activities. Probably there are many stale objects not assigned to any page/activity.
def print_embeddable_stats(embeddable_type, host = "authoring.concord.org")
  ActiveRecord::Base.logger = nil # disable SQL logging
  stats = {}
  count = 0
  LightweightActivity.find_each do |activity|
    count += 1
    if count % 1000 == 0
      print "." # print something to see some progress
    end
    activity.pages.pluck(:id).each do |page_id|
      embeddable_count = PageItem.where(interactive_page_id: page_id, embeddable_type: embeddable_type).count
      if embeddable_count > 0
        unless stats[activity.name]
          runs = activity.runs
          stats[activity.name] = {
            act_name: activity.name,
            act_id: activity.id,
            act_url: Rails.application.routes.url_helpers.activity_url(activity, host: host),
            runs_count: runs.count,
            last_run: runs.count > 0 ? activity.runs.order(:updated_at).last.updated_at : "never",
            embeddable_count: embeddable_count
          }
        else
          stats[activity.name][:embeddable_count] += embeddable_count
        end
      end
    end
  end
  puts # new line after last .
  puts "activity name\tactivity id\tactivity url\truns count\tlast run\t#{embeddable_type} count"
  stats.each do |key, s|
    puts "#{s[:act_name]}\t#{s[:act_id]}\t#{s[:act_url]}\t#{s[:runs_count]}\t#{s[:last_run]}\t#{s[:embeddable_count]}"
  end
  nil
end

# Another version of the same script, but it iterates directly over selected class. If there only a few instances
# this might be faster approach.
def print_embeddable_stats2(embeddable_type, host = "authoring.concord.org")
  ActiveRecord::Base.logger = nil # disable SQL logging
  stats = {}
  count = 0
  embeddable_type.classify.safe_constantize.find_each do |lb|
    count += 1
    if count % 1000 == 0
      print "." # print something to see some progress
    end
    activity = lb.page && lb.page.lightweight_activity
    if activity
      url = Rails.application.routes.url_helpers.activity_url(activity, host: host)
      unless stats[activity.name]
        runs = activity.runs
        stats[activity.name] = {
          act_name: activity.name,
          act_id: activity.id,
          act_url: url,
          runs_count: runs.count,
          last_run: runs.count > 0 ? activity.runs.order(:updated_at).last.updated_at : "never",
          embeddable_count: 1
        }
      else
        stats[activity.name][:embeddable_count] += 1
      end
    end
  end
  puts # new line after last .
  puts "activity name\tactivity id\tactivity url\truns count\tlast run\t#{embeddable_type} count"
  stats.each do |key, s|
    puts "#{s[:act_name]}\t#{s[:act_id]}\t#{s[:act_url]}\t#{s[:runs_count]}\t#{s[:last_run]}\t#{s[:embeddable_count]}"
  end
  nil
end

# Count of pages that don't have a matching lightweight activity
InteractivePage.joins('LEFT OUTER JOIN lightweight_activities ON lightweight_activities.id = interactive_pages.lightweight_activity_id').where('lightweight_activities.id is null').count
