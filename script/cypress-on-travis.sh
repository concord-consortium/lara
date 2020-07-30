cd cypress
npm i
bundle exec rake travis:create_user
cp config/user-config.travis.json config/user-config.json
npm run test:travis
