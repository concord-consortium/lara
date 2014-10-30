set :branch, "staging"
set :domain, "authoring.staging.concord.org"

server domain, :app, :web
role :db, domain, :primary => true

set(:autoscaling_instance_type, "c1.medium")
set(:autoscaling_application, 'LaraStagingLB')
set(:autoscaling_require_keys, true)