namespace :reporting do

  def get_repport_options
    cli = HighLine.new

    # eg: 'super-secret-key'
    ENV["REPORT_SERVICE_TOKEN"]    ||= cli.ask("Report bearer token: ")

    # eg: https://us-central1-report-service-dev.cloudfunctions.net/api/import_structure
    ENV["REPORT_SERVICE_URL"]      ||= cli.ask("Report service URL: ")

    # eg: 'http://app.lara.docker'
    ENV["REPORT_SERVICE_SELF_HOST"] ||= cli.ask("URL for this host: ")
  end

  desc "Publish All activity structures to FireStore report serivce"
  task :publish_structures => :environment do
    get_repport_options()
    self_host = ENV["REPORT_SERVICE_SELF_HOST"]
    LightweightActivity
      .find_in_batches(batch_size: 20) do |group|
        group.each do |act|
          puts "starting #{act.name}"
          payload = ReportServiceResourceSender.new(act, self_host)
          # puts "post result: #{payload.to_json}"
          # puts "wrote #{act.name}"
        end
      end

    Sequence
      .find_in_batches(batch_size: 20) do |group|
        group.each do |seq|
          puts "starting #{seq.name}"
          payload = ReportServiceResourceSender.new(seq, self_host)
          puts "post result: #{payload.to_json}"
          puts "wrote #{seq.name}"
        end
      end
  end

  desc "publish runs to report service"
  task :publish_runs => :environment do
    get_repport_options()
    self_host = ENV["REPORT_SERVICE_SELF_HOST"]
    service_url = ENV["REPORT_SERVICE_URL"]
    service_token = ENV["REPORT_SERVICE_TOKEN"]
    index = 1
    num_runs = Run.count
    Run
      .find_in_batches(batch_size: 20) do |group|
        group.each do |run|
          puts "posting #{index} of #{num_runs} runs: #{run.key}"
          payload = ReportService::RunSender.new(run, self_host)
          puts "content: #{payload.to_json}"
          puts "result: #{payload.send(service_url,service_token)}"
          index = index + 1
        end
      end
  end
end
