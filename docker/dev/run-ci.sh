#!/bin/bash
#
# Run rspec tests in docker environment:
#   – Execute like this: `docker-compose run --rm app ./docker/dev/run-ci.sh`
#   – Or make an alias `alias dci='docker-compose run --rm app ./docker/dev/run-ci.sh'`
#        then type `dci` to start Continuous Integration Testing.
#   – Or run from shell in docker (`docker-compose run --rm bash` … ./docker/dev/run-ci.sh`)

# We have to explicitly set these, because the docker compose files
# Assume master/master and mysql image wont let us create more than
# one DB at startup.  master/master doesn't have create DB permissions.
export RAILS_ENV=test
export DB_NAME=lara_test
export DB_USER=root
export DB_PASSWORD=xyzzy

#
# Prepare spec tests
#
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:test:prepare

#
# Run spec tests
#
bundle exec guard

