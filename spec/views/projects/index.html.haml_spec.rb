require 'spec_helper'

describe "projects/index" do
  before(:each) do
    assign(:projects, [
      stub_model(Project,
        :title => "Title",
        :logo_lara => "Logo",
        :url => "Url",
        :footer => "MyText"
      ),
      stub_model(Project,
        :title => "Title",
        :logo_lara => "Logo",
        :url => "Url",
        :footer => "MyText"
      )
    ])
  end

  it "renders a list of projects" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "li.item", :count => 2
  end
end
