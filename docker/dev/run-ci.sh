#!/bin/bash
# use:  docker-compose run --rm app docker/dev/run-spec.sh
# Run rspec tests in docker environment.
#

#
# Prepare spec tests
#
RAILS_ENV=test bundle exec rake db:test:prepare

#
# Run non-phantom tests:
#
RAILS_ENV=test bundle exec guard
