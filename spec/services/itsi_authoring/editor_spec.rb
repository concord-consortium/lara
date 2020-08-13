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

  let(:page)          { FactoryGirl.create(:interactive_page, name: "page 1", position: 0) }
  let(:interactive)   { FactoryGirl.create(:managed_interactive) }

  before(:each) do
    page.add_interactive interactive
    page.reload
  end

  it "generates JSON for ITSI authoring" do
    editor = ITSIAuthoring::Editor.new(activity)
    itsi_content = editor.to_json
    expect(itsi_content).to have_key(:sections)
  end
end
