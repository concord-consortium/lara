set :domain, "benchmark-authoring.concord.org"

server domain, :app, :web
role :db, domain, primary: true
