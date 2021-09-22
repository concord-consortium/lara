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

  def send_resource(resource, sender_class, opts={})
    get_repport_options()
    self_host = ENV["REPORT_SERVICE_SELF_URL"]
    service_url = ENV["REPORT_SERVICE_URL"]
    service_token = ENV["REPORT_SERVICE_TOKEN"]
    begin
      payload = sender_class.new(resource, opts)
      result = payload.send()
      if (result && result["success"])
        return true
      end
    rescue => e
      Rails.logger.error "Error: #{e}"
    end
    return false
  end

  def send_all_resources(resource_class, sender_class, opts={})
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

  desc "publish student runs to report service"
  task :publish_student_runs => :environment do
    # limit this to portal runs by default:
    where_query = 'remote_endpoint is not null'
    # Or specify remote endpoint substring to match:
    env_value = ENV["REPORT_PUSH_RUN_SELECT_REMOTE"]
    if env_value && env_value.size > 0
      where_query = "remote_endpoint like '%#{env_value}%'"
    end
    runs = Run.where(where_query)
    opts = { send_all_answers: true }
    send_all_resources(runs, ReportService::RunSender, opts)
  end

  desc "publish anonymous runs to report service"
  task :publish_anonymous_runs => :environment do
    runs = Run.where('remote_endpoint is null')
    # allow caller do specify the limit and offset of the query
    limit_env_value = ENV["REPORT_PUSH_RUN_LIMIT"]
    if limit_env_value && limit_env_value.size > 0
      runs = runs.limit(limit_env_value.to_i)
    end
    offset_env_value = ENV["REPORT_PUSH_RUN_OFFSET"]
    if offset_env_value && offset_env_value.size > 0
      runs = runs.offset(offset_env_value.to_i)
    end
    opts = { send_all_answers: true }
    send_all_resources(runs, ReportService::RunSender, opts)
  end

  # Given a CSV file exported from the portal, import `class_hash` value
  # Line Format =  "<clazz_id>, <class_hash>, <learner_id>, <learner_secret_key>"
  # See ClassInfoImportHelper
  desc "import clazz info"
  task :import_clazz_info => :environment do

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
