# Lightweight Activities Runtime and Authoring (LARA)

[![Code Climate](https://codeclimate.com/github/concord-consortium/lara.png)](https://codeclimate.com/github/concord-consortium/lara)
[![Build Status](https://travis-ci.org/concord-consortium/lara.png?branch=master)](https://travis-ci.org/concord-consortium/lara)

This is a Rails application intended to provide a platform for authoring and using "Lightweight" activities.

## Getting started

We use Docker for our local development. We also are currently using rails-lts which is a non-open source version of Rails that includes security backports for Rails 3.2. So your dockerhub user will need access to `concordconsortium/docker-rails-base-private` to do development.

Log in to docker if you haven't already:

    docker login

To get started quickly, run:

    docker-compose up

You can now access LARA at http://localhost:3000  

This will be very slow on OS X and not support a connection to the portal. So we use docker-compose override files to layer additional features onto the basic compose file. These overrides are specified in a `.env` file. To make the initial setup easier there is a `.env-osx-sample` file that contains the standard setup we use. So you can simply:

    cp .env-osx-sample .env
    docker-compose up

**Note:** If you don't have Dinghy setup, you need to follow the directions in the [Dinghy section](#setup-dinghy-on-os-x) before continuing.

Now open LARA at http://app.lara.docker

Sign up a new user at: http://app.lara.docker/users/sign_up

Make that user an admin

    docker-compose exec app bundle exec rake lightweight:admin_last_user

If you see a warning about a confict with a built-in method `OmniAuth`, it can be ignored.

Finally, sign out and sign back in again using http://app.lara.docker/users/sign_in

### SSO with a local portal

Follow the directions in the
[SSO Clients and LARA (authoring) integration](https://github.com/concord-consortium/rigse/blob/master/README.md#sso-clients-and-lara-authoring-integration)
section of the Portal's README.

### Communication with reporting service
To communicate with reporting service you need to make sure you update '.env' with below variables
1. REPORT_SERVICE_URL=https://us-central1-report-service-dev.cloudfunctions.net/api
2. REPORT_SERVICE_TOKEN=

### Automation setup to use same super domain for portal and lara
Automation scripts need portal and lara to be in same super domain.
1. In Lara edit '.env' and add LARA_HOST as authoring.dev.docker and LARA_PROTOCOL as https
2. In Lara edit '.env' and update PORTAL_HOST as learn.dev.docker and PORTAL_PROTOCOL as https

## Users and administration
User authentication is handled by [Devise](https://github.com/plataformatec/devise). Currently, the confirmation plugin is not enabled, so anyone who fills out the registration form at `/users/sign_up` will be automatically confirmed as a user. To get author or administrator privilege, the newly-registered user would need to be given those privileges by an existing admin user (on deployed systems e.g. staging or production).

Some details about the relative authorization privileges of the author, admin and anonymous roles can be found by looking at the Ability class at `app/models/ability.rb`.

## Setup Dinghy on OS X

You only need to do this once. And it can be used with all docker and docker-compose containers.

Startup up a restartable proxying container with a DNS server:

    docker run -d --restart=always -v /var/run/docker.sock:/tmp/docker.sock:ro -v ~/.dinghy/certs:/etc/nginx/certs -p 80:80 -p 443:443 -p 19322:19322/udp -e CONTAINER_NAME=http-proxy --name http-proxy codekitchen/dinghy-http-proxy

Create file /etc/resolver/docker with the following contents.

    nameserver 127.0.0.1
    port 19322

If you have a local webserver running on localhost:80 you either need to move that to a different port, or change the port mapping used by dingy. You can do that by changing the argument `-p 80:80` to `-p [new port]:80`

## Enabling SSL for Dinghy reverse proxy on OS X

**Warning:** Switching to SSL might break some things. You will probably need to
update database entities:
 * external_activities in the Portal
 * runs and sequence_runs in LARA (remote_endpoints)
 * maybe some SSO paths?

Installing certificates, and configuring the docker overlay:
1. install [mkcert](https://github.com/FiloSottile/mkcert) :  `brew install mkcert`
2. Create and install the trusted CA in keychain:   `mkcert -install`
3. Ensure you have a certificate directory: `mkdir -p ~/.dinghy/certs`
4. Make certs:
    1. `cd ~/.dinghy/certs`
    2. `mkcert -cert-file app.lara.docker.crt -key-file app.lara.docker.key app.lara.docker`
    3. `mkcert -cert-file app.portal.docker.crt -key-file app.portal.docker.key app.portal.docker`
    4. For automation:
       1.  `mkcert -cert-file authoring.dev.docker.crt -key-file authoring.dev.docker.key authoring.dev.docker`
       2.  `mkcert -cert-file learn.dev.docker.crt -key-file learn.dev.docker.key learn.dev.docker`
5. You should be using `docker-compose-portal-proxy.yml` in your docker overlays. Check for the
`COMPOSE_FILE=` entry in `.env` includes that overlay.
6. Edit your `.env` file to include `PORTAL_PROTOCOL=https`


## Editing CSS

This project was setup with [Compass](http://compass-style.org/), however, you shouldn't ever need to run `compass watch`. The asset pipeline should take care of itself in development mode.
This project does use [Sass](http://sass-lang.com/) for the stylesheets.

## Themes

The runtime environment supports the idea of themes. Themes mostly take
the form of stylesheets. The themes come in two main families, the CC
theme and the MW theme. You can look at `app/assets/stylesheets/cc-runtime-base.scss` or `app/assets/stylesheets/mw-runtime-base.scss` to see the two main families. Most themes inherit from cc-runtime-base, see for example has-atmosphere.scss which uses `partials/_cc-theme-template.scss`

Theme stylesheets must be added to the config.assets.precompile list in `config/environments/production.rb`
in order to function in production environments.

## Running RSpec tests
While developing, you might wish to run integration tests inside a
Docker container.

First make sure your normal containers are running with `docker-compose up`

For continuously running the tests with guard

    docker-compose exec app docker/dev/run-ci.sh

For running the tests just once

    docker-compose exec app docker/dev/run-spec.sh

It can also be useful to start a bash shell in the container, setup the test environment and then manually run rspec from inside of that shell.  You start a bash shell with

    docker-compose exec app /bin/bash

## Adding code coverage reports
If you set the `COVERAGE_REPORT` environment variable to a non-falsy value a html code coverage report will be generated in the (git ignored) `coverage` directory.

To use this under Docker run `docker-compose up` followed by either

- `docker-compose exec -e COVERAGE_REPORT=true app docker/dev/run-ci.sh`
- `docker-compose exec -e COVERAGE_REPORT=true app docker/dev/run-spec.sh`

## Running Jasmine tests

    docker-compose run -p 8888:8888 --rm app bundle exec rake jasmine

and open [http://localhost:8888](http://localhost:8888)

*Running the tests with PhantomJS is not currently working*
If it was working you could run

    docker-compose run --rm app bundle exec rake jasmine:ci


## Adding Embeddable support
_This may be obsolete as of April 2013_

To support new Embeddables:

* Add a model definition and controller in `app/models/embeddable/` `app/controllers/embeddable/`, respectively. The controller should have the necessary code to accept in-place-editing updates of individual fields in the Embeddable.
* Add the resource to the "embeddable" namespace in `config/routes.rb`.
* Add a view directory at `app/views/embeddable/<embeddable_name>`
* Provide a `_lightweight.html.haml` partial within that view directory (for showing the Embeddable within an InteractivePage)
* Provide a `_author.html.haml` partial as well (for editing the Embeddable)
* Add the Embeddable to the `Embeddable::Types` constant in `app/models/embeddable.rb`.
* Add a human name for the embeddable to the activerecord.models section in config/locales/en.yml
* There may be additional steps needed if the Embeddable is a question (i.e. it prompts the user for some kind of response which needs to be saved). Note `LightweightActivity#questions` for example.

## Current work: reporting
LARA's runtime is being rebuilt to support reporting student answers and progress to [Concord's project portals](https://github.com/concord-consortium/rigse).


## External Scripting & new LARA Plugin API##

* Legacy ExternalScript functionality is described in [external scripts doc](./docs/external-scripts-api.md)
* Proposed API is defined in [LARA API Doc](./docs/lara-plugin-api.md)

## Delayed Job background job processing

see the readme at the [github page](https://github.com/collectiveidea/delayed_job)

Delayed Job will run in synchronous mode unless one of two conditions is
met:

   1. Rails is running in production mode, eg: `RAILS_ENV=production rails s`
   2. The environment variable DELAYEDJOB is set, eg: `DELAYEDJOB=1 rails s`

This configuration check happens in the initializer `config/initializers/delayed_job_config.rb`

To enque a job simply add `handle_asynchronously :method_name` to your models. eg:

    class Device
      def deliver
        # long running method
      end
      handle_asynchronously :deliver
    end

There are other methods for enqueing jobs, but this is the easiest.


## Docker and docker-compose for developers:

For more information about the docker setup look at [the portal docker documentation](https://github.com/concord-consortium/rigse/blob/master/docs/docker.md).

* There is [LARA specific docker documentation](https://github.com/concord-consortium/lara/blob/master/docs/dockerdev.md) in this repo.

## History

This application was developed as a standalone version of the original code developed for the [Lightweight Activities Plugin.](https://github.com/concord-consortium/lightweight-activities-plugin). "Lightweight" has a specific meaning at Concord; briefly, it means an activity or interactive which may be run without Java, and it implies HTML5.


## LARA Interactive API

The LARA Interactive API defines how the runtime javascript of LARA interacts with embedded iframe content. The [documentation can be found here](http://concord-consortium.github.io/lara-interactive-api/docs/)

## Old Non Docker setup

This example assumes that [rvm](https://rvm.io/) is installed. This
 could be a good idea because we use an older version of ruby.

    git clone https://github.com/concord-consortium/lara.git
    cd lara
    bundle install
    cp config/database.sample.yml config/database.yml (need to fix the mysql password and/or user)
    cp config/app_environment_variables.sample.rb config/app_environment_variables.rb
    rake db:setup

Run `rake secret` and copy result to `ENV['SECRET_TOKEN']` in `config/app_environment_variables.rb`.

    rails s

## License

LARA is released under the [MIT License](LICENSE).
