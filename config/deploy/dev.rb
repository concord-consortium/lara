set :deploy_to, "/web/portal"
set :branch, "master"

set :domain, "lightweight-mw.dev.concord.org"
server domain, :app, :web
role :db, domain, :primary => true
