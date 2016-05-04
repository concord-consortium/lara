#!/bin/bash

APP_NAME='lara'

PIDFILE=/$APP_NAME/tmp/pids/server.pid

if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi

bundle exec rake db:create

if [ "$1" == "migrate" ]; then
  bundle exec rake db:migrate
else
  foreman start -d /lara -f /$APP_NAME/docker/prod/Procfile
fi
