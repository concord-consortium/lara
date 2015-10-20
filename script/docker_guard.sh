#!/bin/bash

bundle check || bundle install
bundle exec rake db:test:prepare
bundle exec guard
