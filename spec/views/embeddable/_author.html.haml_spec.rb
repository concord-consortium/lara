require 'spec_helper'

describe "The standard authoring view of the labbook" do
  def warning_text
    I18n.t('LABBOOK.WONT_DISPLAY')
  end

  let(:act) { FactoryGirl.create(:public_activity) }
  let(:_page) { FactoryGirl.create(:page, lightweight_activity: act) }
  let(:_locals) { { page: _page, embeddable: labbook, allow_hide: true } }
  let(:show_in_runtime) { true }
  let(:labbook) do
    lb = Embeddable::Labbook.create
    _page.add_embeddable(lb)
    unless show_in_runtime
      # Snapshot type won't show in runtime, as it also needs to point to another interactive.
      lb.action_type = Embeddable::Labbook::SNAPSHOT_ACTION
    end
    lb
  end

  before :each do
    assign('activity', act)
  end

  describe "When the labbook won't show in the runtime" do
    let(:show_in_runtime) { false }
    it "displays a warning message to authors" do
      render :partial => "embeddable/labbooks/author", :locals => _locals
      expect(rendered).to match (/#{warning_text}/)
      expect(rendered).to have_css(".warning")
    end
  end

  describe "When the labbok will display in the runtime" do
    let(:show_in_runtime) { true }
    it "does not display a warning message to authors" do
      render :partial => "embeddable/labbooks/author", :locals => _locals
      expect(rendered).not_to match (/#{warning_text}/)
      expect(rendered).not_to have_css(".warning")
    end
  end

end
