# spec/lib/tasks/reporting_rake_spec.rb
require 'spec_helper'

describe "reporting:publish_student_runs" do
  include_context "rake"
  let(:run) do
    Run.create( {
      user_id: 1,
      activity_id: 1,
      remote_endpoint: "http://fake.portal.com/1"
    })
  end

  before(:each) do
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return("app.lara.docker")
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("http://foo.com")
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOKEN").and_return("report_service_token")
    allow(ENV).to receive(:[]).with("REPORT_PUSH_RUN_SELECT_REMOTE").and_return(nil)
  end

  it "sends a run to the report service, specifying `send_all_answers`" do
    expected_options = {send_all_answers: true}
    expect(ReportService::RunSender).to receive(:new).with(run, expected_options)
    subject.invoke
  end
end

describe "reporting:publish_anonymous_runs" do
  include_context "rake"
  let(:run) do
    Run.create({
      user_id: 1,
      activity_id: 1
    })
  end

  before(:each) do
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return("app.lara.docker")
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("http://foo.com")
    allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOKEN").and_return("report_service_token")
    allow(ENV).to receive(:[]).with("REPORT_PUSH_RUN_START_DATE").and_return(nil)
  end

  it "sends a run to the report service, specifying `send_all_answers`" do
    expected_options = {send_all_answers: true}
    expect(ReportService::RunSender).to receive(:new).with(run, expected_options)
    subject.invoke
  end
end


describe  "reporting:import_clazz_info" do
  include_context "rake"
  let(:clazz_id)    { 123 }
  let(:learner_id)  { 456 }
  let(:class_hash)  { "C842239D-6447-4CED-89AD-44DD21A9012F" }
  let(:learner_key) { "EDAC877F-209D-494D-B0CB-6F0CE3E577CD" }

  # Portal export file format:
  let(:line_with_all_fields) do
    "#{clazz_id}, #{class_hash}, #{learner_id}, #{learner_key}"
  end

  before(:each) do
    file = Tempfile.new('foo')
    file.write(line_with_all_fields)

    allow(ENV).to receive(:[])
      .with("IMPORT_PORTAL_URL")
      .and_return("http://app.portal.docker/")

    allow(ENV).to receive(:[])
      .with("CLASS_IMPORT_FILENAME")
      .and_return(file.path)

  end

  it "sends a run to the report service, specifying `send_all_answers`" do
    # Just assert no exceptions for now...
    expect { subject.invoke }.not_to raise_error
  end

end

describe "reporting:republish_to_report_service" do
  include_context "rake"

  let!(:portal_published_activity)     { LightweightActivity.create!(name: "pp",  publication_hash: "abc") }
  let!(:never_portal_published_act)    { LightweightActivity.create!(name: "npp", publication_hash: nil) }
  let!(:portal_published_sequence)     { Sequence.create!(title: "pps", publication_hash: "def") }
  let!(:never_portal_published_seq)    { Sequence.create!(title: "npps", publication_hash: nil) }

  before(:each) do
    allow(ReportService).to receive(:configured?).and_return(true)
  end

  it "enqueues SendToReportServiceJob for each portal-published activity and sequence" do
    expect(Delayed::Job).to receive(:enqueue) do |job, *_args|
      expect(job).to be_a(SendToReportServiceJob)
      expect([
        ["LightweightActivity", portal_published_activity.id],
        ["Sequence",            portal_published_sequence.id]
      ]).to include([job.publishable_type, job.publishable_id])
    end.twice
    subject.invoke
  end

  it "does not enqueue for activities or sequences without a publication_hash" do
    enqueued_ids = []
    allow(Delayed::Job).to receive(:enqueue) do |job, *_args|
      enqueued_ids << [job.publishable_type, job.publishable_id]
    end
    subject.invoke
    expect(enqueued_ids).not_to include(["LightweightActivity", never_portal_published_act.id])
    expect(enqueued_ids).not_to include(["Sequence",            never_portal_published_seq.id])
  end
end