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
  let(:library_interactive1) { FactoryGirl.create(:library_interactive,
                                                 name: 'Test Library Interactive 1',
                                                 base_url: 'https://concord.org/'
                                                )}
  let(:library_interactive2) { FactoryGirl.create(:library_interactive,
                                                 name: 'Test Library Interactive 2',
                                                 base_url: 'https://concord.org/'
                                                )}
  let(:managed_interactive1) { FactoryGirl.create(:managed_interactive,
                                                 library_interactive: library_interactive1,
                                                 url_fragment: "test1"
                                                )}
  let(:managed_interactive2) { FactoryGirl.create(:managed_interactive,
                                                 library_interactive: library_interactive2,
                                                 url_fragment: "test2"
                                                )}

  before(:each) do
    page.add_interactive(managed_interactive1)
    page.add_embeddable(managed_interactive2)
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
            name: "Test Library Interactive 1",
            url: "https://concord.org/test1"
          )
        )
      )
    )
    expect(itsi_content[:sections].first).to match(
      hash_including(
        embeddables: include(
          hash_including(
            type: "managed_interactive",
            name: "Test Library Interactive 2",
            url: "https://concord.org/test2"
          )
        )
      )
    )
  end
end
