#!/bin/bash

APP_NAME='lara'

DB_CONFIG=/$APP_NAME/config/database.sample.yml
PIDFILE=/$APP_NAME/tmp/pids/server.pid

if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi

if [ ! -f $DB_CONFIG ]; then
  cp /$APP_NAME/config/database.sample.yml $DB_CONFIG
fi

bundle exec rake db:create
bundle exec rake db:migrate
bundle exec spring rails s -b 0.0.0.0
