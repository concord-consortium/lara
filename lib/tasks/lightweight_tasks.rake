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
end
