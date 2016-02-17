#!/bin/bash

export DB_HOST="10.0.0.5"
export DB_USER="test"
export DB_PASSWORD="test"
export DB_NAME="lara"
export DOCKER_PORTAL_NAME="DOCKER"
export CONCORD_DOCKER_URL="http://10.0.0.5:9000"
export CONCORD_DOCKER_CLIENT_ID="railsdev"
export CONCORD_DOCKER_CLIENT_SECRET="foo"

docker-compose up
