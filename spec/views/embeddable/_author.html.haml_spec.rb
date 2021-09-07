require 'spec_helper'

describe "The standard authoring view of the labbook" do
  def warning_text
    I18n.t('LABBOOK.WONT_DISPLAY')
  end

  let(:activity_stubs){ { active_runs: 0} }
  let(:fake_activity) { double("activity", activity_stubs) }
  let(:_page)         { mock_model(InteractivePage)}
  let(:_section)      { mock_model(Section)}
  let(:_locals)       { { page: _page, embeddable: labbook, allow_hide: true } }
  let(:show_in_runtime) { true }
  let(:labbook) do
    _section.interactive_pages << _page
    lb = Embeddable::Labbook.create
    lb.section = _section
    unless show_in_runtime
      # Snapshot type won't show in runtime, as it also needs to point to another interactive.
      lb.action_type = Embeddable::Labbook::SNAPSHOT_ACTION
    end
    lb
  end

  before :each do
    assign('activity', fake_activity)
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
