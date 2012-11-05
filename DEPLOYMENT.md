# Lightweight Activities Rails Portal Plugin Deployment

## Updating the rails portal with your latest plugin changes
Updating the rails portal is very similar to updating the dummy app.

1. Bump the plugin version in lib/lightweight/version.rb
2. Make sure you've committed and pushed any changes (including the version bump) in the plugin to Github
3. In the rails portal codebase, make sure you're on the lightweight-mw branch:

        git checkout lightweight-mw

4. Update the plugin, and make sure that Gemfile.lock shows the newly bumped version:

        bundle update lightweight_activities
        grep "lightweight" Gemfile.lock

5. Now update the assets

        bundle exec rake assets:precompile

6. Install any new migrations

        bundle exec rake lightweight:install:migrations

7. Commit and push the changes
8. Deploy the branch to the server

        bundle exec cap lightweight-mw deploy deploy:migrate

## Supporting Embeddables
Because Embeddables are not native to this Engine, but rather to the Portal itself, some accomodation needs to be made to support adding each kind of Embeddable to LightweightActivities.

* The engine needs two view partials for each kind of Embeddable it supports, one for display, e.g. `views/embeddable/multiple_choice/_lightweight.html.haml`, and one for authoring, e.g. `views/embeddable/multiple_choice/_author.html.haml`. The two should be largely similar but the latter should use `best_in_place` to support editing of fields.
* Because the Engine uses best\_in\_place as its in-place editor rather than the "official" Rails in-place editor, primarily because it supports jQuery rather than Prototype, tweaks will need to be made to the controllers for each Embeddable. Specifically, the `update` action will need to respond to requests for the `.json` format with this:
        format.json { respond_with_bip @embeddable_model }
  See the embeddable controllers in the dummy application for examples.