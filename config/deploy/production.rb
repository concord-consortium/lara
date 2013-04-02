set :branch, "production"
set :domain, "authoring.concord.org"

server domain, :app, :web
role :db, domain, :primary => true
