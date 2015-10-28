#!/bin/bash

# If guard doesn't trigger, try running vagrant rsync-auto
export RAILS_ENV=test
bundle exec spring rake db:create
bundle exec spring rake db:test:prepare
# -p flag needed here because of a bug / misfeature in guard, for more info:
# https://groups.google.com/forum/#!topic/guard-dev/-tx6yncq1wA
bundle exec guard start -p --no-bundler-warning --no-interactions
