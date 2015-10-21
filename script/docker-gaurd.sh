#!/bin/bash

# gem pristine --all
bundle install
bundle exec rake db:test:prepare
# We have to force polling, because NFS :(
# bundle exec guard start --no-bundler-warning --no-interactions --force-polling  --latency 0.5
bundle exec guard
