require "spec_helper"

describe InteractiveRunHelper do

  # needed so capure_haml is avaialble in #interactive_data_div
  before :each do
    helper.extend Haml::Helpers
    init_haml_helpers
  end

  let(:project)      { FactoryGirl.create(:project) }
  let(:activity)     { FactoryGirl.create(:public_activity, project: project ) }
  let(:page)         { FactoryGirl.create(:page, lightweight_activity: activity) }
  let(:run)          { FactoryGirl.create(:run, run_stubs) }
  let(:sequence_run) { nil }
  let(:interactive)  { FactoryGirl.create(:mw_interactive, authored_state: "{}", name: "test" ) }
  let(:user)         { FactoryGirl.create(:user, { email: "test@example.com" } ) }

  let(:run_stubs) do
    {
      key: "x" * 36,
      activity: activity,
      sequence_run: sequence_run,
      collaboration_run: nil,
      user: user,
      remote_endpoint: 'http://portal.com/remote_endpoint/123',
      class_info_url: 'http://example.com/'
    }
  end

  subject {helper.interactive_data_div(interactive,run)}

  describe "#interactive_data_div(interactive,run)" do
    before :each do
      page.add_interactive(interactive)
      interactive.reload
      page.reload
    end

    describe "without a run" do
      let(:run) { nil }

      it "should not include run specific info" do
        expect(subject).not_to include("data-interactive-run-state-url")
        expect(subject).not_to include("data-loggedin")
        expect(subject).not_to include("data-user-email")
        expect(subject).not_to include("data-class-info-url")
        expect(subject).not_to include("data-get-firebase-jwt-url")
        expect(subject).not_to include("run-key")
        expect(subject).not_to include("run-remote-endpoint")
      end

      it "should include non-run info" do
        expect(subject).to include("data-enable-learner-state")
        expect(subject).to include("data-authored-state")
        expect(subject).to include("data-interactive-id")
        expect(subject).to include("data-interactive-name")
        expect(subject).to include("data-linked-interactive")
      end
    end

    describe "with a run" do

      it "should include run specific info" do
        expect(subject).to include("data-interactive-run-state-url")
        expect(subject).to include("data-loggedin")
        expect(subject).to include("data-user-email")
        expect(subject).to include("data-class-info-url")
        expect(subject).to include("data-get-firebase-jwt-url")
        expect(subject).to include("run-key")
        expect(subject).to include("run-remote-endpoint")
      end

      it "should include non-run info" do
        expect(subject).to include("data-enable-learner-state")
        expect(subject).to include("data-authored-state")
        expect(subject).to include("data-interactive-id")
        expect(subject).to include("data-interactive-name")
        expect(subject).to include("data-linked-interactive")
      end
    end

    describe "with a new unsaved run" do
      let(:run)      { stub_model(Run).as_new_record }

      it "should not include firebase jwt url" do
        expect(subject).not_to include("data-get-firebase-jwt-url")
      end
    end
  end

end
