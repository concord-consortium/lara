require 'spec_helper'

describe "sequences/show" do
  before(:each) do
    @sequence = assign(:sequence, stub_model(Sequence,
      title: "Title",
      description: "MyText"
    ))
    @project = assign(:project, stub_model(Project,
      title: "Title",
      logo: "Logo",
      url: "Url",
      footer: "MyText"
    ))
  end

  it "renders attributes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'div.description', text: 'MyText'
    assert_select 'div.activities'
  end
end
