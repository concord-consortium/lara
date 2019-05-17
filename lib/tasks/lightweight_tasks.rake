namespace :lightweight do
  desc "Make the most-recently-created user an admin. For security reasons, works only in development environment."
  task :admin_last_user => :environment do
    begin
      raise SecurityError unless Rails.env == 'development'
      u = User.last
      u.is_admin = true
      u.save
    rescue SecurityError
      puts "This script only runs in the development environment."
    end
  end

  desc "Publish All activity structures to FireStore report serivce"
  task :publish_to_firestore => :environment do
    cli = HighLine.new

    # eg: 'super-secret-key'
    token = ENV["REPORT_SERVICE_TOKEN"] || cli.ask("Report bearer token: ")

    # eg: https://us-central1-report-service-dev.cloudfunctions.net/api
    url   = ENV["REPORT_SERVICE_URL"]   || cli.ask("Report service API URL: ")

    # eg: 'http://app.lara.docker'
    self_url = ENV["REPORT_SERVICE_SELF_URL"]  || cli.ask("URL for this host")

    # remove trailing slash from urls
    url = url.sub(/^(.*?)\/+$/, '\1')
    self_url = self_url.sub(/^(.*?)\/+$/, '\1')

    num_activities = LightweightActivity.count()
    num_sequences = Sequence.count()
    num_runs = Run.count()

    publish_all = cli.ask("Publish all content? [y/n]").downcase == "y"

    if publish_all || cli.ask("Publish all #{num_activities} activities? [y/n]").downcase == "y"
      index = 1
      LightweightActivity
        .find_in_batches(batch_size: 20) do |group|
          group.each do |act|
            puts "posting #{index} of #{num_activities} activities: #{act.name}"
            content = act.serialize_for_portal(self_url)
            result = HTTParty.post(
              "#{url}/import_structure",
              :body => content.to_json,
              :headers => {
                'Content-Type' => 'application/json',
                'Authorization' => "Bearer #{token}"
              })
            puts "post result: #{result}"
            index = index + 1
          end
        end
    end

    if publish_all || cli.ask("Publish all #{num_sequences} sequences? [y/n]").downcase == "y"
      index = 1
      Sequence
        .find_in_batches(batch_size: 20) do |group|
          group.each do |seq|
            puts "posting #{index} of #{num_sequences} sequences: #{seq.name}"
            content = seq.serialize_for_portal(self_url)
            result = HTTParty.post(
              "#{url}/import_structure",
              :body => content.to_json,
              :headers => {
                'Content-Type' => 'application/json',
                'Authorization' => "Bearer #{token}"
              })
            puts "post result: #{result}"
            index = index + 1
          end
        end
    end

    if publish_all || cli.ask("Publish all #{num_runs} runs? [y/n]").downcase == "y"
      index = 1
      Run
        .find_in_batches(batch_size: 20) do |group|
          group.each do |run|
            puts "posting #{index} of #{num_runs} runs: #{run.key}"
            content = run.serialize_for_reports(self_url)
            result = HTTParty.post(
              "#{url}/import_run",
              :body => content.to_json,
              :headers => {
                'Content-Type' => 'application/json',
                'Authorization' => "Bearer #{token}"
              })
            puts "post result: #{result}"
            index = index + 1
          end
        end
    end
  end
end
