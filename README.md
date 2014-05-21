# Lightweight Activities Runtime and Authoring (LARA)

[![Code Climate](https://codeclimate.com/github/concord-consortium/lara.png)](https://codeclimate.com/github/concord-consortium/lara)
[![Build Status](https://travis-ci.org/concord-consortium/lara.png?branch=master)](https://travis-ci.org/concord-consortium/lara)

This is a Rails application intended to provide a platform for authoring and using "Lightweight" activities.

## Getting started

1. Check out the code:

        git clone https://github.com/concord-consortium/lara.git

2. Install the necessary gems:

        cd lara
        bundle install

3. Initialize the database:

        rake db:setup
        
4. If you have seed data, create it now.

5. Set environment variables, particularly the cookie encryption key, by copying the file `config/app_environment_variables.sample.rb` to `config/app_environment_variables.rb` and editing its values as appropriate. For development purposes, you should just need a cookie key (the 'SECRET_TOKEN' value).

6. Launch the application

        rails s

7. Browse to the app in your browser: [http://localhost:3000/](http://localhost:3000/)

## Editing CSS

This project was setup with [Compass](http://compass-style.org/), however, you shouldn't ever need to run `compass watch`. The asset pipeline should take care of itself in development mode.
This project does use [Sass](http://sass-lang.com/) for the stylesheets.

## Themes

The runtime environment supports the idea of themes. Themes mostly take
the form of stylesheets. The themes come in two main families, the CC
theme and the MW theme. You can look at `app/assets/stylesheets/cc-runtime-base.scss` or `app/assets/stylesheets/mw-runtime-base.scss` to see the two main families. Most themes inherit from cc-runtime-base, see for example has-atmosphere.scss which uses `partials/_cc-theme-template.scss` 


## Users and administration
User authentication is handled by [Devise](https://github.com/plataformatec/devise). Currently, the confirmation plugin is not enabled, so anyone who fills out the registration form (e.g. at [http://localhost:3000/users/sign_up](http://localhost:3000/users/sign_up)) will be automatically confirmed as a user. To get author or administrator privilege, the newly-registered user would need to be given those privileges by an existing admin user (on deployed systems e.g. staging or production).

On a local development instance, you can make an admin user by registering a new user at the link above, then running `rake lightweight:admin_last_user` in your shell. That will make the most-recently-created user an administrator. Needless to say, this task *will not* run in the production environment.

Some details about the relative authorization privileges of the author, admin and anonymous roles can be found by looking at the Ability class at `app/models/ability.rb`.

## Running RSpec tests
If you haven't run tests on this project before, you first need to initialize the test database.

      RAILS_ENV=test rake db:setup

Then, from the application root, run

      RAILS_ENV=test rspec spec

To re-initialize the test database, should that be necessary:

      RAILS_ENV=test rake db:drop db:setup

The RSpec tests live in `spec/`. They use [PhantomJS](http://phantomjs.org/) via [Poltergeist](https://github.com/jonleighton/poltergeist) to run [Capybara](http://jnicklas.github.io/capybara/) tests, so you will need to have PhantomJS installed; it may be [downloaded](http://phantomjs.org/download.html) or installed with Homebrew:

      brew update && brew install phantomjs

If you wish to run tests continuously, Guard is configured; a simple `guard` should start it. Guard will skip some tests tagged "slow" in order to keep cycles short.

### Adding Embeddable support
_This may be obsolete as of April 2013_

To support new Embeddables:

* Add a model definition and controller in `app/models/embeddable/` `app/controllers/embeddable/`, respectively. The controller should have the necessary code to accept in-place-editing updates of individual fields in the Embeddable.
* Add the resource to the "embeddable" namespace in `config/routes.rb`.
* Add a view directory at `app/views/embeddable/<embeddable_name>`
* Provide a `_lightweight.html.haml` partial within that view directory (for showing the Embeddable within an InteractivePage)
* Provide a `_author.html.haml` partial as well (for editing the Embeddable)
* Add the Embeddable's name as a string to the the `Embeddable::Types` constant in `app/models/embeddable.rb`.
* There may be additional steps needed if the Embeddable is a question (i.e. it prompts the user for some kind of response which needs to be saved). Note `LightweightActivity#questions` for example.

## Current work: reporting
LARA's runtime is being rebuilt to support reporting student answers and progress to [Concord's project portals](https://github.com/concord-consortium/rigse).

## Single Sign-On
If you want to use a single sign-on provider, you will need to configure a client in the sign-on authority (e.g. the portal). You should also copy `config/app_environmental_variables.sample.rb` to  `config/app_environmental_variables.rb` and edit as appropriate.

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

There are other methods for enqueing jobs, but this is probably the easiest.


## History
This application was developed as a standalone version of the original code developed for the [Lightweight Activities Plugin.](https://github.com/concord-consortium/lightweight-activities-plugin). "Lightweight" has a specific meaning at Concord; briefly, it means an activity or interactive which may be run without Java, and it implies HTML5.
