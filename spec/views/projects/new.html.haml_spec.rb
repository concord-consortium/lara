require 'spec_helper'

describe "projects/new" do
  before(:each) do
    assign(:project, stub_model(Project,
      :title => "MyString",
      :logo_lara => "MyString",
      :logo_ap => "MyString",
      :project_key => "MyString",
      :url => "MyString",
      :footer => "MyText"
    ).as_new_record)
  end

  it "renders new project form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => projects_path, :method => "post" do
      assert_select "input#project_title", :name => "project[title]"
      assert_select "input#project_logo_lara", :name => "project[logo_lara]"
      assert_select "input#project_logo_ap", :name => "project[logo_ap]"
      assert_select "input#project_project_key", :name => "project[project_key]"
      assert_select "input#project_url", :name => "project[url]"
      assert_select "textarea#project_footer", :name => "project[footer]"
    end
  end
end
