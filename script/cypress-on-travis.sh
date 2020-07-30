# exit on any error
set -e

# start the rails server
PIDFILE=$(pwd)/tmp/pids/server.pid
if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi
echo "Starting rails server ..."
bundle exec rails s -b 0.0.0.0 -d

# setup cypress
cd cypress
npm i
bundle exec rake travis:create_user
cp config/user-config.sample.json config/user-config.json

# DEBUG INFO
ldd /home/travis/.cache/Cypress/4.8.0/Cypress/Cypress

# make sure the rails sever is running (uses wait-on in package.json)
echo "Waiting for rails server to start ..."
npx wait-on http://localhost:3000
echo "Rails server started!"

# run the tests
npm run test:travis

# kill the rails server
echo "Stopping rails server"
kill -9 $(cat $PIDFILE)