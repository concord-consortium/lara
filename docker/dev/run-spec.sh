#!/bin/bash
#
# Run rspec tests in docker environment:
#   – Execute like this: `docker-compose run --rm app ./docker/dev/run-spec.sh`
#   – Or make an alias `alias dspec='docker-compose run --rm app ./docker/dev/run-spec.sh'`
#        then type `dspec` to start Continuous Integration Testing.
#   – Or run from shell in docker (`docker-compose run --rm bash` … ./docker/dev/run-spec.sh`)

export RAILS_ENV=test

#
# Prepare spec tests
#
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:test:prepare

#
# Run spec tests
#
bundle exec rspec spec --tag ~slow --tag ~js
