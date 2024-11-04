set :domain, "authoring.dev.concord.org"

server domain, :app, :web
role :db, domain, primary: true
