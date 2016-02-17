#!/bin/bash

APP_NAME='lara'

DB_CONFIG=/$APP_NAME/config/database.yml
PIDFILE=/$APP_NAME/tmp/pids/server.pid

if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi

if [ ! -f $DB_CONFIG ]; then
  cp /$APP_NAME/config/database.sample.yml $DB_CONFIG
fi

if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rake assets:precompile
fi

if [ "$1" == "migrate-only" ]; then
  bundle exec rake db:create
  bundle exec rake db:migrate
elif [ "$1" == "rails-only" ]; then
  bundle exec rails s -b 0.0.0.0
else
  bundle exec rake db:create
  bundle exec rake db:migrate
  bundle exec rails s -b 0.0.0.0
fi
