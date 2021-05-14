module LibraryInteractiveHelper
  def migrate_library_interactive_options(current_library_interactive)
    migration_options = {
                         'Select a library interactive...' => ''
                        }
    LibraryInteractive.all.each do |li|
      if li.id != current_library_interactive.id
        migration_options["#{li.id} - #{li.name}"] = li.id
      end
    end
    return migration_options
  end
end