namespace :lightweight do
  desc "Make the most-recently-created user an admin. For security reasons, works only in development environment."
  task admin_last_user: :environment do
    begin
      raise SecurityError unless Rails.env == 'development'
      u = User.last
      u.is_admin = true
      u.save
    rescue SecurityError
      puts "This script only runs in the development environment."
    end
  end

  desc "Create an admin user, works only in development environment."
  task create_admin_user: :environment do
    begin
      raise SecurityError unless Rails.env == 'development'
      u = User.create(
        email: "dev_test_user@test.email",
        password: "password",
        is_admin: true
      )
    rescue SecurityError
      puts "This script only runs in the development environment."
    end
  end

  desc "Create an admin user for testing in GitHub CI environment."
  task create_ci_admin_user: :environment do
    begin
      raise SecurityError unless ENV['GITHUB_ACTIONS'] == 'true'
        u = User.create(
          email: "ci_test_user@test.email",
          password: "password",
          is_admin: true
        )
    rescue SecurityError
      puts "This script only runs in the GitHub CI environment."
    end
  end
end
