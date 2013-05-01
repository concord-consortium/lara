require 'spec_helper'

def related_section_rgx
  /<div\s+class=["']related-mod["']>/
end

describe "interactive_pages/show" do

  let(:activity)  { stub_model(LightweightActivity, :id => 1)}

  let(:page) do
    stub_model(InteractivePage,
      :name => "fake page",
      :last? => true,
      :lightweight_activity => activity)
  end

  let(:all_pages) { [page] }

  before :each do
    assign(:session_key, UUIDTools::UUID.random_create.to_s)
    assign(:page, page)
    assign(:all_pages, all_pages)
  end

  it "renders the page title" do
    render
    rendered.should match page.name
  end

  describe "when the activity has a completed related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "related content")}
    it "should render the related section" do
      render
      rendered.should match related_section_rgx
    end
  end

  describe "when the activity has an empty related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "")}
    it "shouldn't render the related section" do
      render
      rendered.should_not match related_section_rgx
    end
  end

  describe "when the activity has a white-space only related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => " \n")}
    it "shouldn't render the related section" do
      render
      rendered.should_not match related_section_rgx
    end
  end

  describe "when the activity has only <br/> entities only related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "<br/><p>\n")}
    it "shouldn't render the related section" do
      render
      rendered.should_not match related_section_rgx
    end
  end

  describe "when the activity has no related content" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => nil)}
    it "shouldn't render the related section" do
      render
      rendered.should_not match related_section_rgx
    end
  end

end
