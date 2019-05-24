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
      payload = sender_class.new(resource, self_host)
      result = payload.send(service_url, service_token)
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
    num_runs = Run.count
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
end
