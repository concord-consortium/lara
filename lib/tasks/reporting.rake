namespace :reporting do

  def get_report_options
    cli = HighLine.new

    # eg: 'super-secret-key'
    ENV["REPORT_SERVICE_TOKEN"]    ||= cli.ask("Report bearer token: ")

    # eg: https://us-central1-report-service-dev.cloudfunctions.net/api
    ENV["REPORT_SERVICE_URL"]      ||= cli.ask("Report service URL: ")

    # eg: 'http://app.lara.docker.noah'
    ENV["REPORT_SERVICE_SELF_URL"] ||= cli.ask("URL for this host: ")
  end

  def send_resource(resource, sender_class, opts={})
    get_report_options()
    self_host = ENV["REPORT_SERVICE_SELF_URL"]
    service_url = ENV["REPORT_SERVICE_URL"]
    service_token = ENV["REPORT_SERVICE_TOKEN"]
    begin
      payload = sender_class.new(resource, opts)
      result = payload.send()
      if (result && result["success"])
        resource.set_status_flag(Run::SentToReportServiceStatusFlag) if resource.respond_to?(:set_status_flag)
        return true
      end
    rescue => e
      Rails.logger.error "Error: #{e}"
    end
    resource.clear_status_flag(Run::SentToReportServiceStatusFlag) if resource.respond_to?(:clear_status_flag)
    return false
  end

  def send_resources(resource_class, sender_class, portal, opts={})
    index = 0
    error_count = 0
    success_count = 0
    start_time = Time.now
    # If portal is set, only send activities or sequences that are in the portal, otherwise send 
    # activities or sequences that are _not_ in the portal
    resource_requirement = portal ? "publication_hash IS NOT NULL" : "publication_hash IS NULL"
    # Only use above resource_requirement if we're sending activities or sequences
    is_activity_or_sequence = [LightweightActivity, Sequence].include? resource_class
    resources = is_activity_or_sequence ? resource_class.where(resource_requirement) : resource_class
    count = resources.count
    puts "==> Sending #{count} #{resource_class.name}s: ..."
    puts ""
    resources
      .find_in_batches(batch_size: 20) do |group|
        group.each do |item|
          if send_resource(item, sender_class, opts)
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
    elapsed = Time.now - start_time
    puts ""
    puts "        ERROR ✖: #{error_count}/#{index}"
    puts "           OK ✔: #{success_count}/#{index}"
    puts "Elapsed seconds: #{elapsed.round(1)}"
    puts ""
  end

  desc "Publish activity structures to FireStore report service"
  task :publish_structures, [:portal] => :environment do |task, args|
    # Send activities
    send_resources(LightweightActivity, ReportService::ResourceSender, args[:portal])

    # Send squences
    send_resources(Sequence, ReportService::ResourceSender, args[:portal])
  end

  desc "publish student runs to report service"
  task publish_student_runs: :environment do
    # limit this to portal runs by default:
    where_query = "remote_endpoint is not null and status & #{Run::SentToReportServiceStatusFlag} = 0"
    # Or specify remote endpoint substring to match:
    env_value = ENV["REPORT_PUSH_RUN_SELECT_REMOTE"]
    if env_value && env_value.present?
      where_query = "remote_endpoint like '%#{env_value}%'"
    end
    runs = Run.where(where_query)
    opts = { send_all_answers: true }
    send_resources(runs, ReportService::RunSender, nil, opts)
  end

  desc "publish anonymous runs to report service"
  task publish_anonymous_runs: :environment do
    runs = Run.where("remote_endpoint is null and status & #{Run::SentToReportServiceStatusFlag} = 0")
    env_value = ENV["REPORT_PUSH_RUN_START_DATE"]
    if env_value && env_value.present?
      runs = runs.where("updated_at >= :date", date: env_value)
    end
    opts = { send_all_answers: true }
    send_resources(runs, ReportService::RunSender, nil, opts)
  end

  # Given a CSV file exported from the portal, import `class_hash` value
  # Line Format =  "<clazz_id>, <class_hash>, <learner_id>, <learner_secret_key>"
  # See ClassInfoImportHelper
  desc "import clazz info"
  task import_clazz_info: :environment do

    def env_value(var_name, prompt, default)
      cli = HighLine.new
      ENV[var_name] ||= cli.ask("#{prompt}: ") { |q| q.default = default}
    end

    env_value "IMPORT_PORTAL_URL", "Portal URL", "http://app.portal.docker"
    import_filename = env_value "CLASS_IMPORT_FILENAME", "Import file", "clazz-learners.csv"

    start_time = Time.now
    line_count = 0
    updated_run_count = 0
    num_lines = File.foreach(import_filename).inject(0) {|c, line| c+1}
    line_interval = (num_lines / 100.0).ceil

    import_file  = File.open(import_filename, 'r')
    import_file.each_line do |import_line|
      new_updates = ClassInfoImportHelper.update_runs_from_csv_line(import_line)
      line_count = line_count + 1
      updated_run_count = updated_run_count + new_updates
      if line_count == 1 || line_count % line_interval == 0
        puts "Processing line: #{line_count} of #{num_lines}"
        puts "    Updated #{updated_run_count} Runs"
      end
    end
    elapsed = (Time.now - start_time).round(2)
    puts "=============================================="
    puts "Elapsed time: #{elapsed} seconds"
    puts "Updated #{updated_run_count} Runs"
  end
end
