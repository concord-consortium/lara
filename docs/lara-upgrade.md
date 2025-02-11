# LARA Upgrade

The purpose of this document is to both plan and track upgrading LARA to the latest Rails+Ruby combo.

## Starting Point

When this document was created LARA used Rails 3.2.22 and Ruby 2.3.7.  The current latest Rails is 7.2.1 which requires Ruby >= 3.1.0.  The latest Ruby version is 3.3.5.  The current minimum Rails community supported LTS version is 7.0.8.4 which requires Ruby >= 2.7.0.  [More info here](https://endoflife.date/rails).

## Goal

The goal of this work is to stop paying for private LTS support and get to Rails 7.1.4 which requires Ruby >= 2.7.0 which has community support until October 1, 2025.  It is the last Rails version that doesn't require Ruby >= 3.1.0 (which will probably break a lot of gems).  At the end we should be using the `ruby27` branch for the `FROM` image with the `Gemfile` setting the Rails version to 7.1.4 (see the "How the versions are interdependent" section for more info).  As a fallback we could release with 7.0.8.4 which requires Ruby >= 2.7.0 but Rails 7.0 will soon go out of community LTS support on April 1, 2025.  As a paid fallback we could use the private LTS version of 6.1.7.19 which requires Ruby >= 2.5.0.

To reduce the amount of code changes need another goal is to keep this a "Rails 3" app that runs in Rails 7.  This means not updating to things like `Webpacker` (a new Javascript build system) as Rails has gone through several updates or update things like file uploading.  The only code changes should be the ones required per the upgrade steps.

## Non-Goals

Initially it was thought we could reduce the amount of upgrade work by deleting as much now dead LARA runtime code (handled now by the Activity Player) as we could.  However we don't have great test coverage of the repo (and no time to add more) so this seems now too risky.  We will not be deleting any code as part of the upgrade **UNLESS** it is code that is dead **AND** requires gems that can't be upgraded.

### How the versions are interdependent

The Rails version is set in the `Gemfile` while the Ruby version is set using the `FROM` image in the Dockerfile (both Dockerfile for production and Dockerfile-dev for development).  The `FROM` image is built from a [GitHub repo](https://github.com/concord-consortium/docker-rails-base) that is currently private as it uses the [Paid Rails LTS](https://railslts.com/) version which requires a basic auth password to pull the gems.  **NOTE**: there are multiple branches in that repo that define different Rails/Ruby combos.  We are using `ruby23` when this document was started.  Here are existing branches for newer pairs:

- `ruby23-rails42`: Ruby 2.3.7 / Rails 4.2.11.17 (still using private LTS gems)
- `ruby25`: Ruby 2.5.9 / Rails 3.2.22.19 (still using private LTS gems)
- `ruby26`: Ruby 2.6 / Rails 6.1.3.2
- `ruby27`: Ruby 2.7 / Rails 6.1.3.2

NOTE: the Rails version in the image can be overridden by the version in the `Gemfile`.  We should not be adding new branches during the upgrade but instead use the branch with the required Ruby version and then use the `Gemfile` to update the Rails version.

## Development Methodology

All work will be done will be merged into the `lara-upgrade` feature branch in case a LARA bug fix needs to be deployed to production during development AND in case we don't reach a usable upgraded version by the end of the development time.  Care should be taken to ensure that the `lara-upgrade` branch always builds which means no broken PRs should be merged into the branch.

Each version upgrade step will be a separate PT story with multiple tasks in the story created from the tasks in the [Rails Upgrade Guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html).  When this work was first added to PT last year a story was created for each task but this resulted in an avalanche of stories.

This document should be updated as the upgrade continues to track the tasks as they are completed along with any notes that may be useful in the future.

## Supplemental Docs

In the Portal Rails upgrade we kept Markdown docs for each major upgrade.  These might be valuable to look at if you get stuck:

- [Portal Rails 4 Upgrade](https://github.com/concord-consortium/rigse/blob/master/docs/rails-4-upgrade.md)
- [Portal Rails 5 Upgrade](https://github.com/concord-consortium/rigse/blob/master/docs/rails-5-upgrade.md)
- [Portal Rails 6 Upgrade](https://github.com/concord-consortium/rigse/blob/master/docs/rails-6-upgrade.md)

## Upgrade Steps

Mark each step with 🚧 when started and with ✅ when completed.  Add a `X` in the Markdown checkbox per task as they are completed to make sure everything is covered, even if no change was needed.

### Organize Gems

To make upgrading the gems in each step easier do the following:

1. Create a `organize-gems` branch off the `lara-upgrade` branch. ✅
2. Place the `source 'https://gems.railslts.com' do ... end` block at the top ✅
3. Sort the remaining gems (inside and outside the groups) in alphabetical order as it will make it easy to see how they are related to each other. ✅
4. Find and comment out all unused development and test gems with a comment block saying why they were commented out.  This will be a combination of looking up what each gem does and figuring out if it is still referenced in the code or deployments.  An example of gems that are no longer used are the `capistrano` gems for deployment.  This step may take a while but it should greatly reduce the upgrade issues due to (dead) gems not supporting newer Rails/Ruby versions.  This should also give a good intro to what all the gems are used for in the code. ✅

### Gem Versions

The table below outlines the active gems in the system with their status code, initial version, current version and max version. The initial and current versions are taken from the Gemfile.lock.  The max gem version was taken from the gem version list at https://rubygems.org/gems/<gem-name>/versions

The table is sorted by rails first, then gems that need upgrading followed by gems that are AM (at max) and don't need upgrading.  You should keep the table sorted this way as it is updated to keep track of changes. The goal is to have all the gems at max with the upgrade confirmed.

Each gem that is upgraded needs to be checked to see if any code changes are needed.  The rails gem changes are already outlined as tasks.  Minor versions normally don't but major version upgrades often break APIs.  In each case the gem's changelog (if available) needs to be examined or other documentation that is available for the gem.  It is best to start with the rubygems.org page for the gem and then check the source code, which is almost always hosted on github, linked to from the rubygems.org page for the gem.

The status codes are:

- AM: at max - gem migrated to max version
- NC: no change
- CU!: confirm major upgrade - check if major gem upgrade breaks API or requires code changes
- CU*: confirm minor upgrade - check if minor gem upgrade requires code changes
- UC!: major upgrade confirmed - all major gem upgrade code changes needed are confirmed
- UC*: minor upgrade confirmed - all minor gem upgrade code changes needed are confirmed
- NU: no upgrade available - gem can't be upgraded
- DG?: gem downgraded - why? this should not happen
- RG: gem removed
- LV: dependency not previously specified in gem file that we have to lock at a specific version

(add more status codes as needed)

| Gem                          | Status       | Initial Version | Current Version | Max Version |
|------------------------------|--------------|-----------------|-----------------|-------------|
| rails (+ rails core...)      |          CU! |          3.2.22 |         6.0.6.1 |       8.0.1 |
| *GEMS AT MAX*                |              |                 |                 |             |
| aws-ses                      |        NC AM |           0.7.1 |           0.7.1 |       0.7.1 |
| chosen-rails                 |       UC* AM |           1.0.1 |          1.10.0 |      1.10.0 |
| compass-blueprint            |        NC AM |           1.0.0 |           1.0.0 |       1.0.0 |
| daemons                      |       UC* AM |           1.1.9 |           1.4.1 |       1.4.1 |
| delayed_job_active_record    |       UC* AM |           4.0.0 |          4.1.11 |      4.1.11 |
| delayed_job_web              |       UC* AM |           1.2.5 |           1.4.4 |       1.4.4 |
| font-awesome-rails           |       UC* AM |         4.3.0.0 |         4.7.0.9 |     4.7.0.9 |
| gon                          |       UC! AM |           5.2.3 |           6.4.0 |       6.4.0 |
| i18n                         |       UC* AM |             n/a |          1.14.7 |      1.14.7 |
| jasmine-jquery-rails         |        NC AM |           2.0.3 |           2.0.3 |       2.0.3 |
| loofah                       |       UC* AM |             n/a |          2.24.0 |      2.24.0 |
| multi_json                   |       UC* AM |          1.13.1 |          1.15.0 |      1.15.0 |
| nested_form                  |        NC AM |           0.3.2 |           0.3.2 |       0.3.2 |
| poltergeist                  |       UC* AM |           1.5.1 |          1.18.1 |      1.18.1 |
| protected_attributes         |           RG |             n/a |             n/a |       1.1.4 |
| rack-environmental           |       UC* AM |           1.3.1 |           1.3.2 |       1.3.2 |
| rack-secure_samesite_cookies |        NC AM |           1.0.2 |           1.0.2 |       1.0.2 |
| rails-controller-testing     |          n/a |             n/a |           1.0.5 |       1.0.5 |
| rake                         |       UC! AM |          10.5.0 |          13.2.1 |      13.2.1 |
| responders                   |       UC* AM |             n/a |           3.1.1 |       3.1.1 |
| ribbons-rails                |        NC AM |           0.0.1 |           0.0.1 |       0.0.1 |
| rspec-activemodel-mocks      |       UC* AM |           1.0.1 |           1.2.1 |       1.2.1 |
| safe_yaml                    |           RG |           1.0.4 |             n/a |       1.0.5 |
| spreadsheet                  |       UC* AM |           1.0.3 |           1.1.2 |       1.3.3 |
| spring-commands-rspec        |        NC AM |           1.0.4 |           1.0.4 |       1.0.4 |
| test-unit                    |       UC* AM |           3.2.3 |           3.6.7 |       3.6.7 |
| timecop                      |       UC* AM |           0.6.3 |          0.9.10 |      0.9.10 |
| turbo-sprockets-rails4       |           AM |             n/a |           1.2.5 |       1.2.5 |
| useragent                    |       UC* AM |          0.10.0 |         0.16.11 |     0.16.11 |
| will_paginate                |       UC! AM |           3.0.7 |           4.0.1 |       4.0.1 |
| *GEMS THAT CAN BE UPGRADED*  |              |                 |                 |             |
| acts_as_list                 |          UC* |           0.3.0 |          0.9.19 |       1.2.4 |
| aws-sdk                      |          CU! |          1.66.0 |          2.0.22 |       3.2.0 |
| better_errors                |          UC! |           1.1.0 |           2.0.0 |      2.10.1 |
| bootsnap                     |          UC* |           1.4.4 |           1.5.1 |      1.18.4 |
| bullet                       |           RG |           5.4.3 |             n/a |       7.2.0 |
| cancancan                    |          UC! |          1.10.1 |           2.3.0 |       3.6.1 |
| capybara                     |          UC* |           2.4.4 |          2.18.0 |      3.40.0 |
| ci_reporter                  |           RM |           1.7.3 |               - |       2.1.0 |
| coffee-rails                 |          UC! |           3.2.2 |           4.2.2 |       5.0.0 |
| compass-rails                |           NC |           3.1.0 |           3.1.0 |       4.0.0 |
| default_value_for            |          UC! |           2.0.3 |           3.6.0 |       4.0.0 |
| devise                       |          UC! |           3.0.1 |           4.9.4 |       4.9.4 |
| dynamic_form                 |          UC* |           1.1.4 |           1.2.0 |       1.3.1 |
| exception_notification       |          UC* |           4.0.1 |           4.4.3 |       4.5.0 |
| factory_girl_rails           |          UC* |           4.3.0 |           4.9.0 |       6.4.3 |
| faker                        |          UC! |           1.2.0 |           2.2.1 |       3.4.2 |
| ffi                          |           LV |           1.15.5           1.16.3 |      1.17.1 |
| haml                         |          UC! |           4.0.5 |           5.2.2 |       6.3.0 |
| highline                     |          UC* |          1.6.21 |          1.7.10 |       3.1.1 |
| httparty                     |          UC* |          0.12.0 |          0.21.0 |      0.22.0 |
| jasmine                      |          UC* |           2.2.0 |          2.99.0 |      3.99.0 |
| jquery-rails                 |          UC! |           3.1.5 |           4.6.0 |       4.6.0 |
| jquery-ui-rails              |          UC* |           4.1.0 |           4.2.1 |       7.0.0 |
| launchy                      |          UC* |           2.4.0 |           2.5.2 |       3.0.1 |
| mysql2                       |          UC* |          0.3.21 |           0.5.6 |       0.5.6 |
| newrelic_rpm                 |       UC! AM |       4.6.0.338 |          9.17.0 |      9.17.0 |
| nokogiri                     |          UC* |          1.10.3 |          1.12.5 |      1.16.7 |
| omniauth                     |          UC* |           1.3.2 |           1.4.2 |       2.1.2 |
| omniauth-oauth2              |          UC* |           1.1.1 |           1.3.0 |       1.8.0 |
| rack-cors                    |          UC! |           0.4.1 |           1.0.6 |       2.0.2 |
| rspec-rails                  |          UC! |           3.8.2 |           4.1.2 |       7.0.1 |
| rubocop                      |          n/a |             n/a |          0.49.1 |       1.6.8 |
| sass-rails                   |          UC! |           3.2.6 |           5.0.8 |       6.0.0 |
| sassc                        |          n/a |             n/a |           2.1.0 |       2.4.0 |
| simplecov                    |       UC* AM |          0.16.1 |          0.22.0 |      0.22.0 |
| spring                       |          UC* |           1.2.0 |           1.7.2 |       4.2.1 |
| sprockets                    |          LV  |           3.7.5 |           3.7.5 |       4.2.1 |
| tinymce-rails                |          UC* |           4.7.9 |           4.9.4 |       7.4.1 |
| uglifier                     |          UC* |           4.1.8 |           4.2.1 |       4.2.1 |
| unicorn                      |       UC! AM |           6.1.0 |           6.1.0 |       6.1.0 |
| uuidtools                    |          UC* |           2.1.4 |           2.1.5 |       2.2.0 |
| web-console                  |          n/a |             n/a |           3.7.0 |       4.2.1 |
| webmock                      |          UC! |          1.24.6 |           3.8.3 |      3.24.0 |

### Upgrade To Rails 4.0.13

1. Create a `upgrade-to-rails-4.0` branch off the `lara-upgrade` branch.✅
2. Upgrade rails gems in `Gemfile` to last 4.0 version: `gem 'rails', '~> 4.0.13'`.  No Ruby upgrade is required. ✅
3. Inside running Docker image run `bundle update rails` ✅
4. Using the gem table in this doc resolve gem dependency issues until the bundle update succeeds AND THEN verify that any code changes needed for the upgraded gems are made.  IT IS BEST to stay within the same major version is you are able.  This will most likely descend into dependency hell as bundler is very slow to resolve versions and many gems depend on other gems.  The best bet is to pin the gems using the current major version in the `Gemfile`, eg change `gem "omniauth", "~> 1.3.2"` to `gem "omniauth", "~> 1"` to give bundler as much leeway to pick a final version.  A fallback is to comment out the gems that have dependency issues to get the rails gem upgraded and then one by one re-enable them by setting them to the current major version and running `bundle update <gem>` where `<gem>` is the gem to upgrade.  You may also see better bundler performance if you pass all the gems that you change on the command line instead of just `rails`.  You can also delete the `Gemfile.lock` file in some instances as that *may* speed up version resolution.  This all really depends on how complex the web of dependencies is in the upgrade and what the weather is like Riverside, Iowa. ✅
5. Complete upgrade tasks in the [3.2 to 4.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0).  Many of these tasks may not require any changes but mark them complete anyway (and maybe make a note no change was required). ✅

- [x] HTTP PATCH (no change required)
- [x] Gemfile
- [x] vendor/plugins (no change required)
- [x] Active Record
  - NOTE: Updates not were made to accomodate the following deprecations:
    - Rails 4.0 has deprecated the old-style hash-based finder API. This means that methods which previously accepted "finder options" no longer do. For example, Book.find(:all, conditions: { name: '1984' }) has been deprecated in favor of Book.where(name: '1984')
    - All dynamic methods except for find_by_... and find_by_...! are deprecated. Here's how you can handle the changes:
        - find_all_by_... becomes where(...).
        - find_last_by_... becomes where(...).last.
        - scoped_by_... becomes where(...).
        - find_or_initialize_by_... becomes find_or_initialize_by(...).
        - find_or_create_by_... becomes find_or_create_by(...).
- [x] Active Resource
- [x] Active Model
- [x] Action Pack
- [x] Active Support (no change required)
- [x] Helpers Loading Order (no change required)
- [x] Active Record Observer and Action Controller Sweeper  (no change required)
- [x] sprockets-rails
- [x] sass-rails (no change required)

6. Create a PR and insure all the tests pass. ✅
7. After review/approval merge the branch into the `lara-upgrade` branch. ✅

### Upgrade To Rails 4.1.16

1. Create a `upgrade-to-rails-4.1` branch off the `lara-upgrade` branch. ✅
2. Upgrade rails gems in `Gemfile` to last 4.1 version: `gem 'rails', '~> 4.1.16'`.  No Ruby upgrade is required. ✅
3. Inside running Docker image run `bundle update rails` ✅
4. Resolve gem dependency issues until the bundle update succeeds. ✅
5. Complete upgrade tasks in the [4.0 to 4.1 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1) ✅

- [x] CSRF protection from remote <script> tags
- [x] Spring
- [x] config/secrets.yml
- [x] Changes to test helper
- [x] Cookies serializer
- [x] Flash structure changes
- [x] Changes in JSON handling
- [x] Usage of return within inline callback blocks
- [x] Methods defined in Active Record fixtures
- [x] I18n enforcing available locales
- [x] Mutator methods called on Relation
- [x] Changes on Default Scopes
- [x] Rendering content from string
- [x] PostgreSQL JSON and hstore datatypes
- [x] Explicit block use for ActiveSupport::Callbacks

6. Create a PR and insure all the tests pass. ✅
7. After review/approval merge the branch into the `lara-upgrade` branch. ✅

### Upgrade To Rails ~~4.2.11.38~~ 4.2.11.23
#### Note:
There is a change in RailsLTS 4.2.11.24 through 4.2.11.38 that involves serialization and YAML.safe_load, which causes things to break in our code.
Documentation here: https://makandracards.com/railslts/521762-change-activerecord-deserialization-cve-2022-32224
For now we will stay at 4.2.11.23 instead of upgrading to 4.2.11.38

1. Create a `upgrade-to-rails-4.2` branch off the `lara-upgrade` branch. ✅
2. Upgrade rails gems in `Gemfile` to last 4.2 version: `gem 'rails', '~> 4.2.11.23'`.  No Ruby upgrade is required. ✅
3. Inside running Docker image run `bundle update rails` ✅
4. Resolve gem dependency issues until the bundle update succeeds. ✅
5. Complete upgrade tasks in the [4.1 to 4.2 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2) ✅

- [x] Web Console
- [x] Responders
- [x] Error handling in transaction callbacks
- [x] Ordering of test cases
- [x] Serialized attributes
- [x] Production log level
- [x] after_bundle in Rails templates
- [x] Rails HTML Sanitizer
- [x] Rails DOM Testing
- [x] Masked Authenticity Tokens
- [x] Action Mailer
- [x] Foreign Key Support

6. Create a PR and insure all the tests pass. ✅
7. After review/approval merge the branch into the `lara-upgrade` branch. ✅

### Upgrade To Rails 5.0.7.2

1. Create a `upgrade-to-rails-5.0` branch off the `lara-upgrade` branch. ✅
2. Upgrade rails gems in `Gemfile` to last 5.0 version: `gem 'rails', '~> 5.0.7.2'`.  No Ruby upgrade is required. ✅
3. Inside running Docker image run `bundle update rails` ✅
4. Resolve gem dependency issues until the bundle update succeeds. ✅
5. Complete upgrade tasks in the [4.2 to 5.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0) ✅

- [x] Ruby 2.2.2+ required (THIS IS ALREADY DONE AS WE ARE ON 2.3.7)
- [x] Active Record Models Now Inherit from ApplicationRecord by Default
- [x] Halting Callback Chains via throw(:abort)
- [x] ActiveJob Now Inherits from ApplicationJob by Default
- [x] Rails Controller Testing
- [x] Autoloading is Disabled After Booting in the Production Environment
- [x] XML Serialization
- [x] Removed Support for Legacy mysql Database Adapter
- [x] Removed Support for Debugger
- [x] Use bin/rails for running tasks and tests
- [x] ActionController::Parameters No Longer Inherits from HashWithIndifferentAccess
- [x] protect_from_forgery Now Defaults to prepend: false
- [x] Default Template Handler is Now RAW
- [x] Added Wildcard Matching for Template Dependencies
- [x] ActionView::Helpers::RecordTagHelper moved to external gem (record_tag_helper)
- [x] Removed Support for protected_attributes Gem
- [x] Removed support for activerecord-deprecated_finders gem
- [x] ActiveSupport::TestCase Default Test Order is Now Random
- [x] ActionController::Live became a Concern
- [x] New Framework Defaults
- [x] Changes with JSON/JSONB serialization

6. Create a PR and insure all the tests pass. ✅
7. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 5.1.7

1. Create a `upgrade-to-rails-5.1` branch off the `lara-upgrade` branch. ✅
2. Upgrade rails gems in `Gemfile` to last 5.1 version: `gem 'rails', '~> 5.1.7'`.  No Ruby upgrade is required.
3. Inside running Docker image run `bundle update rails`  ✅
4. Resolve gem dependency issues until the bundle update succeeds.  ✅
5. Complete upgrade tasks in the [5.0 to 5.1 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1) ✅

- [x] Top-level HashWithIndifferentAccess is soft-deprecated
- [x] application.secrets now loaded with all keys as symbols
- [x] Removed deprecated support to :text and :nothing in render
- [x] Removed deprecated support of redirect_to :back

6. Create a PR and insure all the tests pass. ✅
7. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 5.2.8.1

1. Create a `upgrade-to-rails-5.2` branch off the `lara-upgrade` branch. ✅
2. Upgrade rails gems in `Gemfile` to last 5.2 version: `gem 'rails', '~> 5.2.8.1'`.  No Ruby upgrade is required. ✅
3. Inside running Docker image run `bundle update rails` ✅
4. Resolve gem dependency issues until the bundle update succeeds. ✅
5. Complete upgrade tasks in the [5.1 to 5.2 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2) ✅

- [X] Bootsnap
- [X] Expiry in signed or encrypted cookie is now embedded in the cookies values

6. Create a PR and insure all the tests pass. ✅
7. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 6.0.6.1

1. Create a `upgrade-to-rails-6.0` branch off the `lara-upgrade` branch.
2. **A Ruby upgrade to 2.5 IS required**.

- [x] Change `Dockerfile` and `Dockerfile-dev` to use `ruby-2.5.9` in the `FROM` url INSTEAD OF [docker-rails-base](https://github.com/concord-consortium/docker-rails-base) images.
- [x] Add `RAILS_LTS_PASS` to GitHub LARA repo secrets and update `ci.yml` to pass build arg.
- [x] Get value of `RAILS_LTS_PASS` (in 1Password in the description of the "Rails LTS" secret.  Do no use the login password.) and save in local `.env` file.  This should not result in any updates to be committed, and must be done per developer.
- [x] Run `docker compose build` to rebuild local image using new base image.  Again, no change should be committed.
- [ ] Run `docker compose up` and load LARA in the browser once built to confirm the change worked.  Again, no change should be committed.

4. Upgrade rails gems in `Gemfile` to last 6.0 version: `gem 'rails', '~> 6.0.6.1'`.
5. Inside running Docker image run `bundle update rails`
6. Resolve gem dependency issues until the bundle update succeeds.
7. Complete upgrade tasks in the [5.2 to 6.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0)

- [x] Using Webpacker (SKIP THIS STEP - WEBPACKER IS REPLACED IN LATER RAILS VERSIONS)
- [x] Force SSL (probably not needed since we are behind a gateway on production?)
- [x] Purpose and expiry metadata is now embedded inside signed and encrypted cookies for increased security
- [x] All npm packages have been moved to the @rails scope
- [x] Action Cable JavaScript API Changes
- [x] ActionDispatch::Response#content_type now returns the Content-Type header without modification
- [x] New config.hosts setting
- [x] Autoloading
- [x] Active Storage assignment behavior change
- [x] Custom exception handling applications

6. Create a PR and insure all the tests pass.
7. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 6.1.7.8

1. Create a `upgrade-to-rails-6.1` branch off the `lara-upgrade` branch.
2. Upgrade rails gems in `Gemfile` to last 6.1 version: `gem 'rails', '~> 6.1.7.8 '`.  No Ruby upgrade is required.
3. Inside running Docker image run `bundle update rails`
4. Resolve gem dependency issues until the bundle update succeeds.
5. Complete upgrade tasks in the [6.0 to 6.1 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1)

- [ ] Rails.application.config_for return value no longer supports access with String keys.
- [ ] Response's Content-Type when using respond_to#any
- [ ] ActiveSupport::Callbacks#halted_callback_hook now receive a second argument
- [ ] The helper class method in controllers uses String#constantize
- [ ] Redirection to HTTPS from HTTP will now use the 308 HTTP status code
- [ ] Active Storage now requires Image Processing
- [ ] New ActiveModel::Error class

6. Create a PR and insure all the tests pass.
7. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 7.0.8.4

1. Create a `upgrade-to-rails-7.0` branch off the `lara-upgrade` branch.
2. **A Ruby upgrade to 2.7 IS required**. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-2.7.0` in the `FROM` url.
3. Remove RailsLTS support.  Rails 7.0.x is community supported so RailsLTS is no longer needed.

- [ ] Remove references to `RAILS_LTS_PASS` in `docker-compose.yml`, `DockerFile`, `Dockerfile-dev`, and `ci.yml`
- [ ] Remove `source 'https://gems.railslts.com'` in Gemfile and move rails gems in common gem list
- [ ] Remove `RAILS_LTS_PASS` secret from LARA GitHub repo

4. Upgrade rails gems in `Gemfile` to last 7.0 version: `gem 'rails', '~> 7.0.8.4'`.
5. Inside running Docker image run `bundle update rails`
6. Resolve gem dependency issues until the bundle update succeeds.
7. Complete upgrade tasks in the [6.1 to 7.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)

- [ ] ActionView::Helpers::UrlHelper#button_to changed behavior
- [ ] Spring
- [ ] Sprockets is now an optional dependency
- [ ] Applications need to run in zeitwerk mode
- [ ] The setter config.autoloader= has been deleted
- [ ] ActiveSupport::Dependencies private API has been deleted
- [ ] Autoloading during initialization
- [ ] Ability to configure config.autoload_once_paths
- [ ] ActionDispatch::Request#content_type now returns Content-Type header as it is.
- [ ] Key generator digest class change requires a cookie rotator
- [ ] Digest class for ActiveSupport::Digest changing to SHA256
- [ ] New ActiveSupport::Cache serialization format
- [ ] Active Storage video preview image generation
- [ ] Active Storage default variant processor changed to :vips
- [ ] Rails version is now included in the Active Record schema dump

8. Create a PR and insure all the tests pass.
9. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 7.1.4

1. Create a `upgrade-to-rails-7.1` branch off the `lara-upgrade` branch.
2. Upgrade rails gems in `Gemfile` to last 7.1 version: `gem 'rails', '~> 7.1.4 '`.  No Ruby upgrade is required.
3. Inside running Docker image run `bundle update rails`
4. Resolve gem dependency issues until the bundle update succeeds.
5. Complete upgrade tasks in the [7.0 to 7.1 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)

- [ ] Development and test environments secret_key_base file changed
- [ ] Autoloaded paths are no longer in $LOAD_PATH
- [ ] config.autoload_lib and config.autoload_lib_once
- [ ] ActiveStorage::BaseController no longer includes the streaming concern
- [ ] MemCacheStore and RedisCacheStore now use connection pooling by default
- [ ] SQLite3Adapter now configured to be used in a strict strings mode
- [ ] Support multiple preview paths for ActionMailer::Preview
- [ ] config.i18n.raise_on_missing_translations = true now raises on any missing translation.
- [ ] bin/rails test now runs test:prepare task
- [ ] Import syntax from @rails/ujs is modified
- [ ] Rails.logger now returns an ActiveSupport::BroadcastLogger instance
- [ ] Active Record Encryption algorithm changes
- [ ] New ways to handle exceptions in Controller Tests, Integration Tests, and System Tests

7. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-2.7.0-rails-7.1.4` in the `FROM` url.
8. Create a PR and insure all the tests pass.
9. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 7.2.2

1. Create an `upgrade-to-rails-7.2` branch off the `lara-upgrade` branch.
2. **A Ruby upgrade to 3.1 IS required**. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-3.1.0` in the `FROM` url.
3. Upgrade rails gems in `Gemfile` to last 7.2 version: `gem 'rails', '~> 7.2.2'`.
4. Inside running Docker image run `bundle update rails`
5. Resolve gem dependency issues until the bundle update succeeds.
6. Complete upgrade tasks in the [7.1 to 7.2 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-1-to-rails-7-2)

- [ ] All tests now respect the active_job.queue_adapter config

7. Create a PR and insure all the tests pass.
8. After review/approval merge the branch into the `lara-upgrade` branch.

### Upgrade To Rails 8.0.1

1. Create an `upgrade-to-rails-8` branch off the `lara-upgrade` branch.
2. **A Ruby upgrade to 3.2 IS required**. Change `Dockerfile` and `Dockerfile-dev` to use `ruby-3.2.0` in the `FROM` url.
3. Upgrade rails gems in `Gemfile` to last 7.2 version: `gem 'rails', '~> 8.0.1'`.
4. Inside running Docker image run `bundle update rails`
5. Resolve gem dependency issues until the bundle update succeeds.
6. Complete any upgrade tasks in the [7.2 to 8.0 upgrade guide](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-7-1-to-rails-7-2). **At the time of writing, there were no tasks listed.**
7. Create a PR and insure all the tests pass.
8. After review/approval merge the branch into the `lara-upgrade` branch.
