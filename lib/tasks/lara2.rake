namespace :lara2 do

  desc "List all glossaries with legacy glossary resource ids"
  task :list_glossaries_with_legacy_resource_ids => :environment do
    glossaries = Glossary.where("legacy_glossary_resource_id IS NOT NULL").select([:id, :name, :legacy_glossary_resource_id]).map {|e| {id: e.id, name: e.name, legacy_glossary_resource_id: e.legacy_glossary_resource_id} }
    puts "Found #{glossaries.length} glossaries with legacy glossary resource ids"
    puts JSON.pretty_generate(glossaries)
  end

  desc "Replace all lightweight activity glossary plugins with the glossary model based on the legacy glossary resource id"
  task :migrate_glossary_plugins => :environment do

    plugins = Plugin.where(component_label: "glossary", plugin_scope_type: "LightweightActivity")
    puts "Found #{plugins.length} glossary plugins used in lightweight activities"

    plugins.each do |plugin|
      puts "Loading lightweight activity ##{plugin.plugin_scope_id}"
      activity = LightweightActivity.includes(:glossary).find(plugin.plugin_scope_id)
      if activity.glossary
        puts "Glossary id already set for lightweight activity"
      else
        puts "Glossary id NOT set for lightweight activity, parsing author_data for glossaryResourceId"
        author_data = JSON.parse(plugin.author_data)
        glossary_resource_id = author_data && author_data["glossaryResourceId"]
        if glossary_resource_id
          glossary = Glossary.find_by_legacy_glossary_resource_id(glossary_resource_id)
          if glossary
            puts "Updating lightweight activity ##{plugin.plugin_scope_id} glossary id to #{glossary.id} and saving it"
            activity.glossary = glossary
            activity.save!

            # NOTE: we don't delete the plugin here - there is a seperate task below to do that once we are
            # happy with the migration results
          else
            puts "No glossary with legacy_glossary_resource_id of #{glossary_resource_id} found"
          end
        else
          puts "No glossaryResourceId found in author_data: #{plugin.author_data}"
        end
      end
    end
  end

  desc "Permanently delete glossary_plugins in lightweight activities"
  task :permanently_delete_glossary_plugins => :environment do
    puts "Are you sure you want to PERMANENTLY delete glossary plugins in ALL lightweight activities? Enter 'YES' to confirm:"
    if STDIN.gets.chomp == "YES"
      puts "Deleting glossary plugins used in lightweight activities"
      Plugin.where(component_label: "glossary", plugin_scope_type: "LightweightActivity").delete_all
    else
      puts "Aborting deleting glossary plugins used in lightweight activities"
    end
  end
end