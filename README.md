# Lightweight Activities Standalone

This is a Rails application intended to provide a platform for authoring and using Lightweight activities.

## Getting started

1. Check out the code: if you have access, use

        git clone git@github.com:concord-consortium/lightweight-standalone.git

otherwise, use

        git clone https://github.com/pjmorse/lightweight-standalone.git

2. Install the necessary gems:

        cd lightweight-standalone
        bundle install

3. Initialize the database:

        rake db:drop db:create db:migrate

4. Launch the application

        rails s

6. Browse to the app in your browser: [http://localhost:3000/](http://localhost:3000/)

## Users and administration

Currently, new users aren't confirmed, so anyone who fills out the registration form (e.g. at [http://localhost:3000/users/sign_up](http://localhost:3000/users/sign_up)) will be confirmed as a user. To get author or administrator privilege, the newly-registered user would need to be given those privileges by an existing admin user (on deployed systems e.g. staging or production).

On a local development copy, you can make an admin user by registering a new user at the link above, then running `rake lightweight:admin_last_user` in your shell. That will make the most-recently-created user an administrator. Needless to say, this task *will not* run in the production environment.

Some details about the relative authorization privileges of the author, admin and anonymous roles can be found by looking at the Ability class at `app/models/ability.rb`.

## Deploying

If you have rights to deploy to [http://lightweight-mw.concord.org](http://lightweight-mw.concord.org) or [http://lightweight-mw.staging.concord.org](http://lightweight-mw.staging.concord.org),

    cap production deploy

or
        
    cap staging deploy

respectively, should be sufficient to deploy from the "production" and "staging" branches of this repository. If you're using a different branch, or deploying to a different server, you will want to edit `config/deploy/staging.rb` or `config/deploy/production.rb`.

## Running RSpec tests
From the application root, run

      RAILS_ENV=test rspec spec

You may first need to initialize the test database:

      RAILS_ENV=test rake db:create db:migrate

To re-initialize the test database, use the "initialize the database" command above:

      RAILS_ENV=test rake db:drop db:create db:migrate

The RSpec tests live in `spec/`. They use [PhantomJS](http://phantomjs.org/) via Poltergeist to run Capybara tests, so you will need to have PhantomJS installed; it may be [downloaded](http://phantomjs.org/download.html) or installed with Homebrew:

      brew update && brew install phantomjs

If you wish to run tests continuously, Guard is configured; a simple `guard` should start it.

### Adding Embeddable support

To support new Embeddables:

* Add a model definition and controller in `app/models/embeddable/` `app/controllers/embeddable/`, respectively. The controller should have the necessary code to accept in-place-editing updates of individual fields in the Embeddable.
* Add the resource to the "embeddable" namespace in `config/routes.rb`.
* Add a view directory at `app/views/embeddable/<embeddable_name>`
* Provide a `_lightweight.html.haml` partial within that view directory (for showing the Embeddable within an InteractivePage)
* Provide a `_author.html.haml` partial as well (for editing the Embeddable)
* Add the Embeddable's name as a string to the the `SUPPORTED_EMBEDDABLES` constant in `config/initializers/embeddables.rb`.
* There may be additional steps needed if the Embeddable is a question (i.e. it prompts the user for some kind of response which needs to be saved). Note `LightweightActivity#questions` for example.

## History

This application was developed as a standalone version of the original code developed for the [Lightweight Activities Plugin.](https://github.com/concord-consortium/lightweight-activities-plugin). Much of the code (including this README) has been migrated directly from that plugin.