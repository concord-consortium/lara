set :domain, "authoring.staging.concord.org"

server domain, :app, :web
role :db, domain, primary: true

# set(:autoscaling_instance_type, "c3.large")
# set(:autoscaling_min_size, 1)
# set(:autoscaling_max_size, 6)
# set(:autoscaling_application, 'LaraStagingLB')
# set(:autoscaling_require_keys, true)
# set(:autoscaling_image_master_name, 'lara-staging') # will use 'stage' otherwise