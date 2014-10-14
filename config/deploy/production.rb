set :branch, "production"
set :domain, "authoring.concord.org"

server domain, :app, :web
role :db, domain, :primary => true

set(:autoscaling_instance_type, "c1.medium")
set(:autoscaling_security_groups, %w(lara))
set(:autoscaling_min_size, 2)
set(:autoscaling_max_size, 10)
set(:autoscaling_application, 'LaraProdLB')

after "deploy:restart", "autoscaling:update"