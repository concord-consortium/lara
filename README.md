# Lightweight Activities Runtime and Authoring (LARA)

This is a Rails application intended to provide a platform for authoring and using "Lightweight" activities.

## Getting started

1. Check out the code:

        git clone https://github.com/concord-consortium/lightweight-standalone.git

2. Install the necessary gems:

        cd lightweight-standalone
        bundle install

3. Initialize the database:

        rake db:setup

4. Launch the application

        rails s

6. Browse to the app in your browser: [http://localhost:3000/](http://localhost:3000/)

## Editing CSS
This project uses [Compass](http://compass-style.org/) extensively (but not exclusively) for CSS. If you are editing files in the `app/assets/stylesheets/` tree, you should issue `compass watch` in order to update the built CSS when changes are made.

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
* Add the Embeddable's name as a string to the the `SUPPORTED_EMBEDDABLES` constant in `config/initializers/embeddables.rb`.
* There may be additional steps needed if the Embeddable is a question (i.e. it prompts the user for some kind of response which needs to be saved). Note `LightweightActivity#questions` for example.

## Current work: reporting

LARA's runtime is being rebuilt to support reporting student answers and progress to [Concord's project portals](https://github.com/concord-consortium/rigse).

## Single Signon ##

If you want to use a single signon provider, you will need to configure a client in the signon authority (eg: The portal).  You should also copy `config/app_environmental_variables.sample.rb` to  `config/app_environmental_variables.rb` and edit as approprtiate. 


## History

This application was developed as a standalone version of the original code developed for the [Lightweight Activities Plugin.](https://github.com/concord-consortium/lightweight-activities-plugin).