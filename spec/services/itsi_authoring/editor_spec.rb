require "spec_helper"

describe ITSIAuthoring::Editor do
  let(:author)        { FactoryGirl.create(:author) }
  let(:activity)      {
    activity = FactoryGirl.create(:activity)
    activity.user = author
    activity.save
    activity.theme = FactoryGirl.create(:theme)
    activity
  }

  let(:page)                { FactoryGirl.create(:interactive_page,
                                                 name: "page 1",
                                                 position: 0
                                                 )}
  let(:library_interactive) { FactoryGirl.create(:library_interactive,
                                                 name: 'Test Library Interactive',
                                                 base_url: 'https://concord.org/'
                                                )}
  let(:managed_interactive) { FactoryGirl.create(:managed_interactive,
                                                 library_interactive: library_interactive,
                                                 url_fragment: "test"
                                                )}

  before(:each) do
    page.add_interactive(managed_interactive)
    page.reload
    activity.pages << page
  end

  it "generates JSON for ITSI authoring" do
    editor = ITSIAuthoring::Editor.new(activity)
    itsi_content = editor.to_json
    expect(itsi_content).to have_key(:sections)
    expect(itsi_content[:sections].length).to eq(1)
    expect(itsi_content[:sections].first).to match(
      hash_including(
        interactives: include(
          hash_including(
            type: "managed_interactive",
            name: "Test Library Interactive",
            url: "https://concord.org/test"
          )
        )
      )
    )
  end
end
