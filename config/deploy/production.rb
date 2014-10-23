set :branch, "production"
set :domain, "authoring.production.concord.org"

server domain, :app, :web
role :db, domain, :primary => true

set(:autoscaling_instance_type, "c1.medium")
set(:autoscaling_security_groups, %w(lwmw))
set(:autoscaling_min_size, 2)
set(:autoscaling_max_size, 10)
set(:autoscaling_application, 'LaraProdLB')

after "deploy:restart", "autoscaling:update"