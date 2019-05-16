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

    # eg: https://us-central1-report-service-dev.cloudfunctions.net/api/import_structure
    url   = ENV["REPORT_SERVICE_URL"]   || cli.ask("Report service URL: ")

    # eg: 'http://app.lara.docker'
    self_url = ENV["REPORT_SERVICE_SELF_URL"]  || cli.ask("URL for this host")

    LightweightActivity
      .find_in_batches(batch_size: 20) do |group|
        group.each do |act|
          puts "starting #{act.name}"
          content = act.serialize_for_portal(self_url)
          result = HTTParty.post(
            url,
            :body => content.to_json,
            :headers => {
              'Content-Type' => 'application/json',
              'Authorization' => "Bearer #{token}"
            })
          puts result
          puts "wrote #{act.name}"
        end
      end

    Sequence
      .find_in_batches(batch_size: 20) do |group|
        group.each do |seq|
          puts "starting #{seq.name}"
          content = seq.serialize_for_portal(self_url)
          result = HTTParty.post(
            url,
            :body => content.to_json,
            :headers => {
              'Content-Type' => 'application/json',
              'Authorization' => "Bearer #{token}"
            })
          puts result
          puts "wrote #{seq.name}"
        end
      end
  end
end
