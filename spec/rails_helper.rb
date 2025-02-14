require "factory_bot_rails"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths = [Rails.root.join('spec', 'factories').to_s]
    FactoryBot.reload
  end
end