#!/bin/bash

rm /myapp/tmp/pids/server.pid
export RAILS_ENV=development
bundle exec spring rake db:create
bundle exec spring rake db:migrate
bundle exec spring rails s -b 0.0.0.0
