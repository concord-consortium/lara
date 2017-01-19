require 'spec_helper'

describe "The standard authoring view of the labbook" do
  def warning_text
    I18n.t('LABBOOK.WONT_DISPLAY')
  end

  let(:lb_stubs)      { {show_in_runtime?: false,
                         action_label: 'appears on button',
                         why_not_show_in_runtime: 'LABBOOK.UNKNOWN_REASON' } }
  let(:activity_stubs){ { active_runs: 0} }
  let(:fake_activity) { double("activity", activity_stubs) }
  let(:labbook)       { mock_model(Embeddable::Labbook, lb_stubs)}
  let(:_page)         { mock_model(InteractivePage)}
  let(:_locals)       { { page: _page, embeddable: labbook, allow_hide: true } }

  before :each do
    assign('activity', fake_activity)
  end

  describe "When the labbook won't show in the runtime" do
    it "displays a warning message to authors" do
      render :partial => "embeddable/labbooks/author", :locals => _locals
      expect(rendered).to match (/#{warning_text}/)
      expect(rendered).to have_css(".warning")
    end
  end

  describe "When the labbok will display in the runtime" do
    let(:lb_stubs)      { {show_in_runtime?: true, action_label: 'appears on button' } }
    it "does not display a warning message to authors" do
      render :partial => "embeddable/labbooks/author", :locals => _locals
      expect(rendered).not_to match (/#{warning_text}/)
      expect(rendered).not_to have_css(".warning")
    end
  end

end
