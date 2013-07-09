require 'spec_helper'

describe "projects/new" do
  before(:each) do
    assign(:project, stub_model(Project,
      :title => "MyString",
      :logo => "MyString",
      :url => "MyString",
      :footer => "MyText"
    ).as_new_record)
  end

  it "renders new project form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => projects_path, :method => "post" do
      assert_select "input#project_title", :name => "project[title]"
      assert_select "input#project_logo", :name => "project[logo]"
      assert_select "input#project_url", :name => "project[url]"
      assert_select "textarea#project_footer", :name => "project[footer]"
    end
  end
end
