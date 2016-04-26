app_dir = "/lara"

working_directory app_dir

pid "#{app_dir}/tmp/unicorn.pid"

worker_processes (ENV['NUM_UNICORN_PROCESSES'] || 1).to_i
listen "/tmp/unicorn.sock", :backlog => 64
timeout 30
