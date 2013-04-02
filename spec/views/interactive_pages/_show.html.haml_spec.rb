require 'spec_helper'

def related_section_rgx
  /<div\s+class=["']related["']>/
end

def renderIt(locals)
  assign(:session_key,"3"*16)
  render :partial => "interactive_pages/show", :locals => locals
end

describe "interactive_pages/_show" do

  let(:activity)  { stub_model(LightweightActivity, :id => 1)}

  let(:page) do
    stub_model(InteractivePage,
      :name => "fake page",
      :last? => true,
      :lightweight_activity => activity)
  end

  it "renders the page title" do
    renderIt(:page => page, :all_pages => [page])
    rendered.should match page.name
  end
  describe "when the activity has a completed related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "related content")}
    it "should render the related section" do
      renderIt({:page => page, :all_pages => [page]})
      rendered.should match related_section_rgx
    end
  end

  describe "when the activity has an empty related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "")}
    it "shouldn't render the related section" do
      renderIt({:page => page, :all_pages => [page]})
      rendered.should_not match related_section_rgx
    end
  end

  describe "when the activity has a white-space only related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => " \n")}
    it "shouldn't render the related section" do
      renderIt({:page => page, :all_pages => [page]})
      rendered.should_not match related_section_rgx
    end
  end

  describe "when the activity has only <br/> entities only related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "<br/><p>\n")}
    it "shouldn't render the related section" do
      renderIt({:page => page, :all_pages => [page]})
      rendered.should_not match related_section_rgx
    end
  end

  describe "when the activity has no related content" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => nil)}
    it "shouldn't render the related section" do
      renderIt({:page => page, :all_pages => [page]})
      rendered.should_not match related_section_rgx
    end
  end

end
