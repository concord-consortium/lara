# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec,
  cmd: 'bundle exec spring rspec --tag ~slow --tag ~js',
  # To run all tets, just hit "<return>" in the console.
  all_after_pass: false,
  all_on_start: false do

  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
  watch(%r{^spec/factories/.+\.rb$})  { "spec" }

  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/controllers" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch('app/controllers/embeddable/embeddables_controller.rb') { 'spec/controllers/embeddable' }
  watch('app/models/ability.rb')                      { "spec/models/user_spec.rb" }
  watch('app/models/embeddable.rb')                   { "spec/models/embeddable" }
  watch('app/models/embeddable/answer.rb')            { "spec/models/embeddable" }

  # NOTE: Jasmine Guard hasn't been working.
  # To run *Jasmine* tests: `bundle exec rake jasmine:ci`
end
