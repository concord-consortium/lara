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

  desc "Publish All activity structures to FireStore report serivce"
  task :publish_structures => :environment do
    get_repport_options()
    self_host = ENV["REPORT_SERVICE_SELF_URL"]
    service_url = ENV["REPORT_SERVICE_URL"]
    service_token = ENV["REPORT_SERVICE_TOKEN"]
    index = 0
    error_count = 0
    successes = 0
    sart_time = Time.now

    # Send activities
    LightweightActivity
      .find_in_batches(batch_size: 20) do |group|
        group.each do |act|
          puts "starting #{act.name}"
          payload = ReportService::ResourceSender.new(act, self_host)
          result = payload.send(service_url, service_token)
          if (result && result["success"])
            successes = successes + 1
          else
            error_count = error_count + 1
            puts "Error: Activity #{act.id}"
          end
          index = index + 1
        end
      end

    # Send squences:
    Sequence
      .find_in_batches(batch_size: 20) do |group|
        group.each do |seq|
          puts "starting #{seq.name}"
          payload = ReportService::ResourceSender.new(seq, self_host)
          result = payload.send(service_url,service_token)
          if (result && result["success"])
            successes = successes + 1
          else
            error_count = error_count + 1
            puts "Error: Sequence: #{seq.id}"
          end
          index = index + 1
        end
      end

      puts "ERROR: #{error_count}/#{index}"
      puts "OK: #{successes}/#{index}"
      elapsed = Time.now - sart_time
      puts "Elapsed seconds: #{elapsed.round()}"
  end

  desc "publish runs to report service"
  task :publish_runs => :environment do
    get_repport_options()
    self_host = ENV["REPORT_SERVICE_SELF_URL"]
    service_url = ENV["REPORT_SERVICE_URL"]
    service_token = ENV["REPORT_SERVICE_TOKEN"]
    index = 0
    error_count = 0
    successes = 0
    sart_time = Time.now
    num_runs = Run.count
    Run
      .find_in_batches(batch_size: 20) do |group|
        group.each do |run|
          puts "posting #{index + 1} of #{num_runs}"
          payload = ReportService::RunSender.new(run, self_host)
          result = payload.send(service_url,service_token)
          if (result && result["success"])
            successes = successes + 1
          else
            error_count = error_count + 1
            puts "error: #{run.key}"
          end
          index = index + 1
        end
      end
    puts "ERROR: #{error_count}/#{index}"
    puts "OK: #{successes}/#{index}"
    elapsed = Time.now - sart_time
    puts "Elapsed seconds: #{elapsed.round()}"
  end
end
