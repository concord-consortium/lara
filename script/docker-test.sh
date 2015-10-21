#!/bin/bash

bundle exec rake db:test:prepare
bundle exec spring guard start --no-bundler-warning --no-interactions
