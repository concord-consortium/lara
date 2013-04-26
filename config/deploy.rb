require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :application, "lightweight-standalone"
set :repository,  "git://github.com/concord-consortium/lara.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :stages, %w(staging production dev)

set :default_stage, "staging"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "link in some shared resources, such as database.yml"
  task :shared_symlinks do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    # 2012-11-07: Not sure if the below are needed at this point, but here they are
    run "ln -nfs #{shared_path}/config/aws_s3.yml #{release_path}/config/aws_s3.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/mailer.yml #{release_path}/config/mailer.yml"
    run "ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
    run "ln -nfs #{shared_path}/config/initializers/subdirectory.rb #{release_path}/config/initializers/subdirectory.rb"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system" # paperclip file attachment location
    # This is part of the setup necessary for using newrelics reporting gem
    # run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/google_analytics.yml #{release_path}/config/google_analytics.yml"
    run "ln -nfs #{shared_path}/config/app_environment_variables.rb #{release_path}/config/app_environment_variables.rb"
  end
end

# Production stage
set :user, "deploy"
set :deploy_to, "/web/portal"
set :branch, "master"
set :use_sudo, false

after 'deploy:update_code', 'deploy:shared_symlinks'
