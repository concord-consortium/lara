# Lightweight Activities Rails Portal Plugin

This is a plugin which will eventually provide authoring, runtime and reporting support for lightweight, browser based activities within the CC rails portal.

## Getting started

1. Check out the code

        git clone https://github.com/concord-consortium/lightweight-activities-plugin.git

2. Install the necessary gems

        cd lightweight-activities-plugin
        bundle install

3. Go to the dummy app directory

        cd spec/dummy

4. Initialize the database, with seed data

        bundle exec rake db:drop db:create db:migrate db:seed

5. Launch the dummy rails app

        bundle exec rails s

6. Browse to the app in your browser: [http://localhost:3000/lightweight/activity/1](http://localhost:3000/lightweight/activity/1)

## Running RSpec tests
From the main plugin directory, run

      RAILS_ENV=test bundle exec rspec spec

You may first need to initialize the test database:

      cd spec/dummy
      RAILS_ENV=test rake db:create db:migrate
      cd -

The RSpec tests live in spec/.

## Editing and making changes
All of the code for the plugin lives within app/, db/, and lib/.

If you make any changes to the plugin's assets (js, css, images), you'll
need to precompile them in the dummy app:

      cd spec/dummy
      bundle exec rake assets:precompile

If you create any database migrations, you'll have to pull them into the
dummy app:

      cd spec/dummy
      bundle exec rake lightweight:install:migrations

### Adding Embeddable support

To support new Embeddables:

* We assume the Embeddable already has a model definition and controller in the host portal. The controller should have the necessary code to accept in-place-editing updates of individual fields in the Embeddable.
* Add a view directory at `app/views/embeddable/<embeddable_name>`
* Provide a `_lightweight.html.haml` partial within that view directory (for showing the embeddable within an InteractivePage)
* Provide a `_author.html.haml` partial as well (for editing the embeddable)
* Add the Embeddable's name as a string to the list of supported Embeddables at `lib/lightweight/version.rb` (it's the `SUPPORTED_EMBEDDABLES` constant).