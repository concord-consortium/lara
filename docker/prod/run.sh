#!/bin/bash

APP_NAME='lara'

cp /$APP_NAME/config/database.sample.yml /$APP_NAME/config/database.yml
cp /$APP_NAME/docker/prod/app_environment_variables.rb /$APP_NAME/config/app_environment_variables.rb

if [ "$1" == "delayed_job" ]; then

  /$APP_NAME/docker/prod/delayed_job

else

  PIDFILE=/$APP_NAME/tmp/pids/server.pid

  if [ -f $PIDFILE ]; then
    rm $PIDFILE
  fi

  bundle exec rake db:create

  if [ "$1" == "migrate" ]; then
    bundle exec rake db:migrate
  else
    foreman start -f Procfile
  fi
fi
