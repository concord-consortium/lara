set :branch, "staging"
set :domain, "authoring.staging.concord.org"

server domain, :app, :web
role :db, domain, :primary => true

set :autoscaling_instance_type, "c1.medium"
set :autoscaling_application, 'LaraStagingLB'
set :autoscaling_group_extra_options, {propagate_at_launch: true}

# after "deploy:restart", "autoscaling:update"  