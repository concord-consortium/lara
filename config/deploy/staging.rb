set :deploy_to, "/web/portal"
set :branch, "staging"

set :domain, "lightweight-mw.staging .concord.org"
server domain, :app, :web
role :db, domain, :primary => true
