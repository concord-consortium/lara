require "spec_helper"

describe InteractiveRunHelper do

  # needed so capure_haml is avaialble in #interactive_data_div
  before :each do
    helper.extend Haml::Helpers
    init_haml_helpers
  end

  let(:act_stubs)  {{}}
  let(:page_stubs) {{}}

  let(:activity)     { mock_model(LightweightActivity, act_stubs) }
  let(:page)         { mock_model(InteractivePage, page_stubs)    }
  let(:run)          { mock_model(Run, run_stubs)                 }
  let(:new_run)      { stub_model(Run).as_new_record }
  let(:sequence_run) { nil }
  let(:interactive)  { mock_model(MwInteractive, interactive_stubs) }
  let(:user_stubs)   { {
    email: "test@example.com",
    most_recent_authentication: {
      provider: nil
    }
  } }
  let(:user)         { mock_model(User, user_stubs) }

  let(:run_stubs) do
    {
      key: "x" * 36,
      activity: activity,
      sequence_run: sequence_run,
      collaboration_run: nil,
      user: user,
      class_info_url: 'http://example.com/'
    }
  end

  let(:interactive_stubs) do
    {
      authored_state: "{}",
      name: "test"
    }
  end

  describe "#interactive_data_div(interactive,run)" do
    describe "without a run" do
      subject {helper.interactive_data_div(interactive,nil)}

      it "should not include run specific info" do
        expect(subject).not_to include("data-interactive-run-state-url")
        expect(subject).not_to include("data-loggedin")
        expect(subject).not_to include("data-user-email")
        expect(subject).not_to include("data-class-info-url")
        expect(subject).not_to include("data-get-firebase-jwt-url")
      end

      it "should include non-run info" do
        expect(subject).to include("data-enable-learner-state")
        expect(subject).to include("data-authored-state")
        expect(subject).to include("data-interactive-id")
        expect(subject).to include("data-interactive-name")
      end
    end

    describe "with a run" do
      subject {helper.interactive_data_div(interactive,run)}

      it "should include run specific info" do
        expect(subject).to include("data-interactive-run-state-url")
        expect(subject).to include("data-loggedin")
        expect(subject).to include("data-user-email")
        expect(subject).to include("data-class-info-url")
        expect(subject).to include("data-get-firebase-jwt-url")
      end

      it "should include non-run info" do
        expect(subject).to include("data-enable-learner-state")
        expect(subject).to include("data-authored-state")
        expect(subject).to include("data-interactive-id")
        expect(subject).to include("data-interactive-name")
      end
    end

    describe "with a new unsaved run" do
      subject {helper.interactive_data_div(interactive,new_run)}

      it "should not include firebase jwt url" do
        expect(subject).not_to include("data-get-firebase-jwt-url")
      end
    end
  end

end
