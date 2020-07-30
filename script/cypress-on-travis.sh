# start the rails server
PIDFILE=$(pwd)/tmp/pids/server.pid
if [ -f $PIDFILE ]; then
  rm $PIDFILE
fi
bundle exec rails s -b 0.0.0.0 -d

# setup cypress
cd cypress
npm i
bundle exec rake travis:create_user
cp config/user-config.sample.json config/user-config.json

# make sure the rails sever is running (uses wait-on in package.json)
npx wait-on http://localhost:3000

# run the tests
npm run test:travis

# kill the rails server
kill -9 $(cat $PIDFILE)