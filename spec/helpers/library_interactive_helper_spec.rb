require "spec_helper"

describe LibraryInteractiveHelper do
  let (:library_interactive1) { FactoryBot.create(:library_interactive,
       name: 'Test Library Interactive 1',
       base_url: 'http://foo.com/',
       thumbnail_url: nil
      ) }
  let (:library_interactive2) { FactoryBot.create(:library_interactive,
       name: 'Test Library Interactive 2',
       base_url: 'http://bar.com/',
       thumbnail_url: nil
      ) }

  describe "#migrate_library_interactive_options" do
    it "should return a hash of library interactives that are not the library interactive to be migrated" do
      li1_key = "#{library_interactive1.id} - #{library_interactive1.name}"
      li2_key = "#{library_interactive2.id} - #{library_interactive2.name}"
      options = helper.migrate_library_interactive_options(library_interactive1)

      expect(options).not_to have_key(li1_key)
      expect(options).to have_key(li2_key)
    end
  end
end