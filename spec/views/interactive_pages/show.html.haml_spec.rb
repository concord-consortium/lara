require 'spec_helper'

def related_section_rgx
  /<div\s+class=["']related-mod["']>/
end

describe "interactive_pages/show" do

  let(:activity)  { stub_model(LightweightActivity, id: 1)}

  let (:page) do
    p = FactoryGirl.create(:page, name: "fake page", lightweight_activity: activity, embeddable_display_mode: 'carousel')
    allow(p).to receive_messages(last?: true)
    p
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:run)  { FactoryGirl.create(:run, {activity: activity, user: user}) }

  let(:all_pages) { [page] }

  before :each do
    assign(:page, page)
    assign(:run, run)
    assign(:all_pages, all_pages)
  end

  it "renders the page title" do
    render
    expect(rendered).to match page.name
  end

  describe "when the activity has a completed related content section" do
    let(:activity) { stub_model(LightweightActivity, id: 1, related: "related content")}
    it "should render the related section" do
      render
      expect(rendered).to match related_section_rgx
    end
  end

  describe "when the activity has an empty related content section" do
    let(:activity) { stub_model(LightweightActivity, id: 1, related: "")}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe "when the activity has a white-space only related content section" do
    let(:activity) { stub_model(LightweightActivity, id: 1, related: " \n")}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe "when the activity has only <br/> entities only related content section" do
    let(:activity) { stub_model(LightweightActivity, id: 1, related: "<br/><p>\n")}
    it "shouldn't render the related section" do
      render
      expect(rendered).not_to match related_section_rgx
    end
  end

  describe "when the activity has no related content" do
    let(:activity) { stub_model(LightweightActivity, id: 1, related: nil)}
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
  end

  describe 'the completion page' do
    before(:each) do
      assign(:activity, activity)
    end
    let (:page) do
      p = FactoryGirl.create(:page, name: "fake page", lightweight_activity: activity, is_completion: completion_flag)
      allow(p).to receive_messages(last?: true)
      p
    end
    describe "when the page is a a completion page" do
      let(:completion_flag) { true }
      it 'should render the completion template' do
        render
        expect(rendered).to render_template(partial: 'interactive_pages/_show_completion')
      end
      it 'should not render the regular show template' do
        render
        expect(rendered).not_to render_template(partial: 'interactive_pages/_show')
      end
      it 'should include a congratulations message' do
        render
        expect(rendered).to have_css(".congratulations-block")
      end
    end
    describe "when the page is not a completion page" do
      let(:completion_flag) { false }
      it 'should render the normal show template' do
        render
        expect(rendered).to render_template(partial: 'interactive_pages/_show')
      end
      it 'should not render the completion template' do
        render
        expect(rendered).not_to render_template(partial: 'interactive_pages/_show_completion')
      end
    end
  end
end
