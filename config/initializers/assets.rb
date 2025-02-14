Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "javascripts")
Rails.application.config.assets.paths << Gem.loaded_specs["chosen-rails"].full_gem_path + "/vendor/assets/javascripts"
Rails.application.config.assets.precompile += %w(chosen-jquery.js)
Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "stylesheets")
Rails.application.config.assets.paths << Gem.loaded_specs["chosen-rails"].full_gem_path + "/vendor/assets/stylesheets"
Rails.application.config.assets.precompile += %w(chosen.css)