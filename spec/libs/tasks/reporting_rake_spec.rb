# spec/lib/tasks/reporting_rake_spec.rb
require 'spec_helper'

describe "reporting:publish_runs" do
  include_context "rake"
  let(:run) do
    Run.create( {
      user_id: 1,
      activity_id: 1,
      remote_endpoint: "http://fake.portal.com/1"
    })
  end

  before(:each) do
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return("noah.lara.com")
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("http://foo.com")
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOKEN").and_return("report_service_token")
  end

  it "sends a run to the report service, specifying `send_all_answers`" do
    expected_options = {:send_all_answers=>true}
    expect(ReportService::RunSender).to receive(:new).with(run, expected_options)
    subject.invoke
  end

end
