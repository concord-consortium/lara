require "bundler/capistrano"
require "capistrano/ext/multistage"
require "haml"
require "delayed/recipes"

# experimental: create autoscaling instances from EC2 instance
require "capistrano-autoscaling"
require 'capistrano/cowboy'

load "config/deploy_extras/copy_activities.rb"

set :application, "lightweight-standalone"
set :repository,  "git://github.com/concord-consortium/lara.git"
set :rails_env,   "production" #added for delayed job

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :stages, %w(staging production dev benchmark demo)

set :default_stage, "staging"

def render(file,opts={})
  template = File.read(file)
  haml_engine = Haml::Engine.new(template)
  output = haml_engine.render(nil,opts)
  output
end

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you"re still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path,"tmp","restart.txt")}"
  end

  desc "link in some shared resources, such as database.yml"
  task :shared_symlinks do
    run "mkdir -p #{shared_path}/system/"
    run "mkdir -p #{shared_path}/snapshots"
    run "mkdir -p #{shared_path}/pids"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    # 2012-11-07: Not sure if the below are needed at this point, but here they are
    run "ln -nfs #{shared_path}/config/aws_s3.yml #{release_path}/config/aws_s3.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/initializers/site_keys.rb #{release_path}/config/initializers/site_keys.rb"
    run "ln -nfs #{shared_path}/config/initializers/subdirectory.rb #{release_path}/config/initializers/subdirectory.rb"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system" # paperclip file attachment location
    run "ln -nfs #{shared_path}/snapshots #{release_path}/public/snapshots" # paperclip file attachment location
    # This is part of the setup necessary for using newrelics reporting gem
    # run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/config/google_analytics.yml #{release_path}/config/google_analytics.yml"
    run "ln -nfs #{shared_path}/config/app_environment_variables.rb #{release_path}/config/app_environment_variables.rb"
    run "ln -nfs #{shared_path}/pids #{release_path}/tmp/pids"
  end

  task :require_branch do
    if fetch(:branch, nil).nil?
      abort "==============================================================================\n" +
            "   \e[31mFAILED: a branch is required\e[0m\n" + # control codes make the text red
            "     set a branch with `-S branch=[something]` (it could be a tag)\n" +
            "=============================================================================="
    end
  end

  desc "save a version.yml file on the server based on deployed branch"
  task :put_version do
    run "echo 'version: #{fetch(:branch)}' > #{release_path}/config/version.yml"
  end

end

# Production stage
set :user, "deploy"
set :deploy_to, "/web/portal"
set :use_sudo, false

before 'deploy:update_code', 'deploy:require_branch'
after 'deploy:update_code', 'deploy:put_version'

before "deploy:assets:precompile", "deploy:shared_symlinks"

# delayed job tasks:
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

require "./config/boot"

#############################################################
#  Maintenance mode
#############################################################
namespace :deploy do
  namespace :web do
    task :disable, roles: :web do

      on_rollback { delete "#{shared_path}/system/maintenance.html"    }

      site_name = Capistrano::CLI.ui.ask("site name? ") { |q| q.default = "LARA"         }
      back_up   = Capistrano::CLI.ui.ask("back up?   ") { |q| q.default = "in 12 minutes" }
      message   = Capistrano::CLI.ui.ask("message?   ") { |q| q.default = ""              }

      maintenance = render("./app/views/layouts/maintenance.haml",
                           {
                             back_up: back_up,
                             message: message,
                             site_name: site_name
                           })

      # File.open(File.expand_path("~/Desktop/index.html"),"w") do |f|
      #   f.write(maintenance)
      # end
      run "mkdir -p #{shared_path}/system/"
      put maintenance, "#{shared_path}/system/maintenance.html",
                       mode: 0644
    end
  end

## Autoscale EC2 / AMI / ELB Config:
set(:autoscaling_region, "us-east-1e")
set(:autoscaling_require_keys, false)
# set(:autoscaling_access_key_id, "PUTYOURAWSACCESSKEYIDHERE")
# set(:autoscaling_secret_access_key, "PUTYOURAWSSECRETACCESSKEYHERE")
# Make the default behavior be to NOT autoscale
set(:autoscaling_create_image, false)
set(:autoscaling_create_group, false)
set(:autoscaling_create_policy, false)
set(:autoscaling_create_launch_configuration, false)
set(:autoscaling_instance_type, "c1.medium")
set(:autoscaling_security_groups, %w(lara))
set(:autoscaling_min_size, 1)
set(:autoscaling_max_size, 2)
set(:autoscaling_application, 'LaraDevLB')
set(:autoscaling_group_extra_options, {propagate_at_launch: true})
end
