set :branch, "staging"
set :domain, "authoring.staging.concord.org"

server domain, :app, :web
role :db, domain, :primary => true
