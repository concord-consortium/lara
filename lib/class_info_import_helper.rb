
module ClassInfoImportHelper

  def self.remote_endpoint_path_for(import_line)
    clazz_id, class_hash, l_id, l_key = import_line.strip.split(",")
    learner_key = l_key.present? ? l_key : l_id
    portal_url = ENV["IMPORT_PORTAL_URL"]
    "#{portal_url}/dataservice/external_activity_data/#{learner_key.strip}"
  end

  def self.class_info_url_path(class_id)
    portal_url = ENV["IMPORT_PORTAL_URL"]
    "#{portal_url}/api/v1/classes/#{class_id}"
  end

  # Params:
  # +import_line+: should look like this:
  #     "<clazz_id>, <class_hash>, <learner_id>, <learner_secret_key>"
  def self.update_runs_from_csv_line(import_line)
    remote_endpoint = remote_endpoint_path_for(import_line)
    clazz_id, class_hash, learner_id, learner_key, user_id, resource_link_id = import_line.strip.split(",")
    updated_run_count = 0
    info_url = class_info_url_path(clazz_id)
    platform_id = ENV["IMPORT_PORTAL_URL"]
    attrs = {
      class_info_url: info_url,
      context_id: class_hash,
      platform_id: platform_id,
      platform_user_id: user_id,
      resource_link_id: resource_link_id
    }
    SequenceRun
      .where(remote_endpoint: remote_endpoint)
      .each do |srun|
        srun.update(attrs)
        # Child runs:
        srun.runs.each do |run|
          run.update(attrs)
          updated_run_count = updated_run_count + 1
        end
    end

    Run
      .where(remote_endpoint: remote_endpoint)
      .each do |run|
        run.update(attrs)
        updated_run_count = updated_run_count + 1
      end
    
    return updated_run_count
  end

end
