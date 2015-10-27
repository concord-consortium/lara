#!/bin/bash

# If guard doesn't trigger, try running vagrant rsync-auto
export RAILS_ENV=test
bundle exec spring rake db:create
bundle exec spring rake db:test:prepare
bundle exec guard start --no-bundler-warning --no-interactions
