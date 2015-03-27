require 'spec_helper'

def related_section_rgx
  /<div\s+class=["']related-mod["']>/
end

describe "interactive_pages/show" do

  let(:activity)  { stub_model(LightweightActivity, :id => 1)}

  let (:page) do
    p = FactoryGirl.create(:page, :name => "fake page", :lightweight_activity => activity, :embeddable_display_mode => 'carousel')
    allow(p).to receive_messages(:last? => true)
    [3,1,2].each do |i|
      embed = FactoryGirl.create(:xhtml, :name => "embeddable #{i}", :content => "This is the #{ActiveSupport::Inflector.ordinalize(i)} embeddable")
      p.add_embeddable(embed, i)
    end
    p
  end

  let (:run) { Run.new }

  let(:all_pages) { [page] }

  before :each do
    assign(:session_key, UUIDTools::UUID.random_create.to_s)
    assign(:page, page)
    assign(:run, run)
    assign(:all_pages, all_pages)
  end

  it "renders the page title" do
    render
    expect(rendered).to match page.name
  end

  describe "when the activity has a completed related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "related content")}
    it "should render the related section" do
      render
      expect(rendered).to match related_section_rgx
    end
  end

  describe "when the activity has an empty related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "")}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe "when the activity has a white-space only related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => " \n")}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe "when the activity has only <br/> entities only related content section" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => "<br/><p>\n")}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe "when the activity has no related content" do
    let(:activity) { stub_model(LightweightActivity, :id => 1, :related => nil)}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe 'when the embeddable display mode is carousel and there are embeddables' do
    it 'should have a div with class jcarousel' do
      render
      expect(rendered).to have_css('div.jcarousel')
    end

    it 'should have next and previous links' do
      render
      expect(rendered).to have_css('a.jcarousel-prev')
      expect(rendered).to have_css('a.jcarousel-next')
    end
  end
end
