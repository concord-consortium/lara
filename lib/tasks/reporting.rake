namespace :reporting do

  def get_repport_options
    cli = HighLine.new

    # eg: 'super-secret-key'
    ENV["REPORT_SERVICE_TOKEN"]    ||= cli.ask("Report bearer token: ")

    # eg: https://us-central1-report-service-dev.cloudfunctions.net/api
    ENV["REPORT_SERVICE_URL"]      ||= cli.ask("Report service URL: ")

    # eg: 'http://app.lara.docker.noah'
    ENV["REPORT_SERVICE_SELF_URL"] ||= cli.ask("URL for this host: ")
  end

  def send_resource(resource, sender_class)
    get_repport_options()
    self_host = ENV["REPORT_SERVICE_SELF_URL"]
    service_url = ENV["REPORT_SERVICE_URL"]
    service_token = ENV["REPORT_SERVICE_TOKEN"]
    begin
      payload = sender_class.new(resource)
      result = payload.send()
      if (result && result["success"])
        return true
      end
    rescue => e
      Rails.logger.error "Error: #{e}"
    end
    return false
  end

  def send_all_resources(resource_class, sender_class)
    index = 0
    error_count = 0
    success_count = 0
    sart_time = Time.now
    count = resource_class.count
    puts "==> Sending #{count} #{resource_class.name}s: ..."
    puts ""
    resource_class
      .find_in_batches(batch_size: 20) do |group|
        group.each do |item|
          if send_resource(item, sender_class)
            success_count = success_count + 1
            putc "."
          else
            error_count = error_count + 1
            putc "✖"
          end
          index = index + 1
        end
        puts "\n✖ #{error_count}  |  ✔ #{success_count}"
      end
    elapsed = Time.now - sart_time
    puts ""
    puts "        ERROR ✖: #{error_count}/#{index}"
    puts "           OK ✔: #{success_count}/#{index}"
    puts "Elapsed seconds: #{elapsed.round(1)}"
    puts ""
  end

  desc "Publish All activity structures to FireStore report serivce"
  task :publish_structures => :environment do
    # Send activities
    send_all_resources(LightweightActivity, ReportService::ResourceSender)

    # Send squences:
    send_all_resources(Sequence, ReportService::ResourceSender)
  end

  desc "publish runs to report service"
  task :publish_runs => :environment do
    send_all_resources(Run, ReportService::RunSender)
  end

  desc "import clazz info"
  task :import_clazz_info => :environment do

    def remote_endpoint_path(learner_key)
      portal_url = ENV["IMPORT_PORTAL_URL"]
      "#{portal_url}/dataservice/external_activity_data/#{learner_key}"
    end

    def class_info_url_path(class_id)
      portal_url = ENV["IMPORT_PORTAL_URL"]
      "#{portal_url}/api/v1/classes/#{class_id}"
    end

    def env_value(var_name, prompt, default)
      cli = HighLine.new
      ENV[var_name] ||= cli.ask("#{prompt}: ") { |q| q.default = default}
    end

    env_value "IMPORT_PORTAL_URL", "Portal URL", "http://app.portal.docker/"
    import_filename = env_value "CLASS_IMPORT_FILENAME", "Import file", "clazz-learners.csv"

    start_time = Time.now
    line_count = 1
    updated_srun_count = 0
    updated_run_count = 0
    num_lines = File.foreach(import_filename).inject(0) {|c, line| c+1}
    line_interval = (num_lines / 100.0).ceil

    import_file  = File.open(import_filename, 'r')
    import_file.each_line do |import_line|
      if line_count == 1 || line_count % line_interval == 0
        puts "Processing line: #{line_count} of #{num_lines}"
        puts "    Updated #{updated_srun_count} SequenceRuns"
        puts "    Updated #{updated_run_count} Runs"
      end
      clazz_id, class_hash, user_id, learner_key, resource_link_id = import_line.strip.split(",")
      remote_endpoint = remote_endpoint_path(learner_key)
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
          srun.update_attributes(attrs)
          updated_srun_count = updated_srun_count + 1
          # Child runs:
          srun.runs.each do |run|
            run.update_attributes(attrs)
            updated_run_count = updated_run_count + 1
          end
      end

      Run
        .where(remote_endpoint: remote_endpoint)
        .each do |run|
          run.update_attributes(attrs)
          updated_run_count = updated_run_count + 1
        end
      line_count = line_count + 1
    end
    elapsed = (Time.now - start_time).round(2)
    puts "=============================================="
    puts "Elapsed time: #{elapsed} seconds"
    puts "Updated #{updated_srun_count} SequenceRuns"
    puts "Updated #{updated_run_count} Runs"
  end
end
