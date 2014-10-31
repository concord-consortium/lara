set :branch, "production"
set :domain, "authoring.production.concord.org"

server domain, :app, :web
role :db, domain, :primary => true

set(:autoscaling_instance_type, "c1.medium")
set(:autoscaling_security_groups, %w(lwmw))
set(:autoscaling_min_size, 1)
set(:autoscaling_max_size, 6)
set(:autoscaling_application, 'LaraProdLB')
set(:autoscaling_require_keys, true)
set(:autoscaling_image_master_name, 'lara-production') # will use 'stage' otherwise