set :deploy_to, "/web/portal"
set :branch, "production"

set :domain, "lightweight-mw.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
