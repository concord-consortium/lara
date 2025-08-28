# Lightweight Activities Runtime and Authoring (LARA)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/concord-consortium/lara)
[![Code Climate](https://codeclimate.com/github/concord-consortium/lara.png)](https://codeclimate.com/github/concord-consortium/lara)
[![Build Status](https://travis-ci.org/concord-consortium/lara.png?branch=master)](https://travis-ci.org/concord-consortium/lara)

This is a Rails application intended to provide a platform for authoring and using "Lightweight" activities.

## Getting started

We use Docker for our local development. We also are currently using rails-lts which is a non-open source version of Rails that includes security backports for Rails 3.2. So your dockerhub user will need access to `ghcr.io/concord-consortium/docker-rails-base-private` to do development.

Create GitHub personal access token and select the read:packages scope to download container images and read their metadata

More details: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic

 Save your token as an environment variable:

    export CR_PAT=YOUR_TOKEN

Log in to docker if you haven't already:

    echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin

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

## GitHub Codespaces

Github Codespaces is a cloud-based development environment. We are currently using it to do development work on LARA and
Portal since it’s proven difficult to do local development on those codebases on M1 MacBooks.

Github’s documentation for Codespaces can be found at [here](docs.github.com/en/codespaces).

You will need to set up separate codespaces for LARA and the Portal.

Use of Codespaces incurs an hourly cost. The amount is not a lot, but it should be kept in mind. Codespaces will shut themselves down
automatically after a period of inactivity, but it would be best to manually shut them down when you’re done working in order to
minimize cost.

You can use Codespaces in web browser or you can connect to selected machine from desktop Visual Studio Code if you
install a Codespaces extension.

### Basic setup

- Your GitHub account needs to have Codespaces activated by the organization admin.
- Go to the github.com page for the repository you will be working on.
- Click on the Code button, then click the Codespaces tab, and then click the “Create codespace on master” button.
- LARA should be fine with 2-core machine, however 4-core seems to work significantly faster.

Once machine is up and running, most of the steps described for local development are still valid for GH Codespaces.
The main difference is that you should copy `.env-gh-codespaces-sample` to `.env` (instead of `.env-osx-sample`),
there's no need for Dinghy setup, and LARA and Portal hosts will be significantly different. However, everything
you need to do in practice is described below.

1. Run:
    ```
      cp .env-gh-codespaces-sample .env
    ```

1. Open Portal GitHub Codespace, run `echo ${CODESPACE_NAME}` in terminal, and set `PORTAL_CODESPACE_NAME` variable
in LARA's `.env` file.

1. Set `REPORT_SERVICE_TOKEN` in LARA's `.env` file following instructions that can be found there.

1. Create GitHub personal access token and select the `read:packages` scope to download container images and read their metadata. More details: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic

    Save your token as an environment variable and log in to docker:
    ```
      export CR_PAT=YOUR_TOKEN
      echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
    ```

1. Run
    ```
      docker-compose up
    ```

1. Once the app has started, open "Ports" tab in Visual Studio Code. Find a process that uses port 3000 and change its
visibility to public (right click on "Private" -> Port Visibility -> Public). You should see an updated address in
"Local Address" column. You can open this URL in the web browser and LARA should load. It seems it's necessary to do it
each time you run `docker-compose up`.

1. Now, your LARA instance should work with Portal, Activity Player and basic reports. You can login to LARA
through `Localhost` (Portal running on another GH Codespace) using `admin`, `password` credentials. You are now logged
in with admin@concord.org in LARA, however this user is not actually an admin in LARA. Run the following command in
terminal in the LARA Codespaces:
    ```
      docker-compose exec app bundle exec rake lightweight:admin_last_user
    ```

1. If you don't need Portal, you can skip all the instructions related to it. Finally, add `users/sign_up` to the URL and create a new user there.
   You can make this user an admin by running following command:
    ```
      docker-compose exec app bundle exec rake lightweight:admin_last_user
    ```

## Editing CSS

This project uses [Sass](http://sass-lang.com/) for the stylesheets.

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

## Cypress

### Running tests
In the dev environment:

- `npm run test:dev`

In the staging environment:

- `CYPRESS_password=<password> npm run test:cypress:open:staging``


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

# LARA Cypress tests

## Setup and configuration

First, install NPM packages and Cypress:

```
npm install
```

Then, you need to provide credentials of an admin user (=> user able to import and delete activities) for 
test environments that you are planning to use:

 - dev
 - staging
 - production
 
Note that these credentials must work on `/user/sign_in` page, e.g. http://authoring.staging.concord.org/users/sign_in. 
You **can't** use Portal to login (tests should not depend on Portal).

These credentials and any other user-specific configuration should be specified in `config/user-config.json`. 
Copy existing sample and modify it:

```
cp config/user-config.sample.json config/user-config.json
```

Also, If you are using dev environment, you might want to change local LARA URL depending on your docker 
setup. You might need to modify `baseUrl` option defined in `config/user-config.json` in the `dev` section.

Other environment properties (e.g. LARA URLs) are specified in `config/environments.json` file (e.g. LARA URLs).
This file should not be changed unless some new configuration is added. 

## Additional notes about configuration

You can also temporarily overwrite any configuration option using env variables with `CYPRESS_` prefix. E.g.:

- `CYPRESS_username=johndoe@test.email npm run test:dev`
- `CYPRESS_baseUrl=http://localhost:3000 npm run test:dev`

## Running tests

- `npm run test:dev`
- `npm run test:staging`
- `npm run test:production`

## Writing tests, workflow and patterns

1. Most of the tests will require some activity or sequence to exist. This test material should be stored in 
`cypres/fixtures` directory, as an exported JSON. That way it's possible to test one material in various environments.

    ```javascript
    context('Test example', function () {
      let activityUrl
      beforeEach(() => {
        cy.login()
        cy.importMaterial("activities/test-activity.json").then(url =>
          activityUrl = url
        )
      })
      afterEach(() => {
        cy.deleteMaterial(activityUrl)
      })
      
      it('some test case', () => {
        // ...
      })
    })
    ``` 

    Note that the activity should be always deleted in `afterEach`. This block is executed even 
    if the test fails.

2. Tests should not depend on other tests. In case of LARA, it means that every test should import and delete activity.
 Otherwise, if an activity is reused, it means that some run state is already present and that might affect the test
 execution. It's okay to test such behavior, but that should be probably just one, longer test. 

3. Use `[Cypress]` prefix for test activity and sequence names, as it's quite likely that some activities
won't get deleted in the process. It will be easy to clean them up. `importMaterial` command will fail if the material
is missing this prefix.

4. Take a look at `cypres/support/commands.js`. This file implements LARA-specific helpers that will make test 
implementation simpler. Existing commands at the moment:

    - login
    - logout
    - importMaterial
    - deleteMaterial
    - requestWithToken (CSRF)
    - visitActivityPage

Examples of tests following these recommendations:
- `cypress/integration/runtime/state-saving.js`
- `cypress/integration/runtime/multiple-choice-question.js`
- `cypress/integration/runtime/sequence-completed-activity.js`


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
