namespace :travis do

  desc "create_user"
  task :create_user => :environment do

    # NOTE: this must match settings in cypress/config/user-config.sample.json for the travis environment
    email = "travis@example.com"
    password = "travis_password"

    unless User.find_by_email(email)
      user = User.create(
        email: email,
        password: password,
        is_author: true,
        is_admin: true,
      )
    end
  end

end