#!/bin/bash

bundle check || bundle install
# you could optionally recreate the DB every time.
# bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rails s -b 0.0.0.0
