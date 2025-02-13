require 'spec_helper'

describe ReportService do
  let(:user)         { FactoryBot.create(:user) }
  let(:activity)     { FactoryBot.create(:activity, id: 23, name: "Test Activity") }
  let(:sequence)     { FactoryBot.create(:sequence, id: 1, title: "Test Sequence", lightweight_activities: [activity])}
  let(:run)          { FactoryBot.create(:run, {key: "012345678901234567890123456789123456", activity: activity})}

  describe "#report_url" do
    before(:each) do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("REPORT_SERVICE_SELF_URL").and_return("http://test.host")
      allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("https://us-central1-report-service-dev.cloudfunctions.net/api")
      allow(ENV).to receive(:[]).with("REPORT_URL").and_return("https://portal-report.concord.org/branch/master/index.html")
      allow(ENV).to receive(:[]).with("REPORT_SERVICE_TOOL_ID").and_return("authoring.test.concord.org")
    end

    describe "when the run is anonymous or doesn't include Portal info" do
      it "returns Portal Report URL with runKey param" do
        expect(ReportService::report_url(run, activity)).to eq(
          "https://portal-report.concord.org/branch/master/index.html?" +
          "firebase-app=report-service-dev&" +
          "sourceKey=authoring.test.concord.org&" +
          "runKey=012345678901234567890123456789123456&" +
          "activity=http%3A%2F%2Ftest.host%2Factivities%2F23&" +
          "resourceUrl=http%3A%2F%2Ftest.host%2Factivities%2F23"
        )
      end
    end

    describe "when the run has Portal info" do
      let(:run_with_portal_info) do
        FactoryBot.create(:run, {
          key: "012345678901234567890123456789123456",
          activity: activity,
          user: user,
          class_info_url: "https://test.portal.com/api/v1/classes/123",
          platform_id: "https://test.portal.com",
          platform_user_id: "ABC",
          resource_link_id: "321"
        })
      end

      it "returns Portal Report URL with runKey param" do
        expect(ReportService::report_url(run_with_portal_info, activity)).to eq(
          "https://portal-report.concord.org/branch/master/index.html?" +
          "firebase-app=report-service-dev&" +
          "sourceKey=authoring.test.concord.org&" +
          "class=https%3A%2F%2Ftest.portal.com%2Fapi%2Fv1%2Fclasses%2F123&" +
          "offering=https%3A%2F%2Ftest.portal.com%2Fapi%2Fv1%2Fofferings%2F321&" +
          "reportType=offering&" +
          "studentId=ABC&" +
          "auth-domain=https%3A%2F%2Ftest.portal.com"
        )
      end
    end

    describe "when REPORT_SERVICE_URL points to production Report Service" do
      before(:each) do
        allow(ENV).to receive(:[]).with("REPORT_SERVICE_URL").and_return("https://us-central1-report-service-pro.cloudfunctions.net/api")
      end

      it "sets firebase-app to report-service-pro" do
        expect(ReportService::report_url(run, activity)).to eq(
          "https://portal-report.concord.org/branch/master/index.html?" +
          "firebase-app=report-service-pro&" +
          "sourceKey=authoring.test.concord.org&" +
          "runKey=012345678901234567890123456789123456&" +
          "activity=http%3A%2F%2Ftest.host%2Factivities%2F23&" +
          "resourceUrl=http%3A%2F%2Ftest.host%2Factivities%2F23"
        )
      end
    end

    describe "when sequence is provided" do
      it "adds activityIndex param" do
        expect(ReportService::report_url(run, activity, sequence)).to eq(
          "https://portal-report.concord.org/branch/master/index.html?" +
          "firebase-app=report-service-dev&" +
          "sourceKey=authoring.test.concord.org&" +
          "runKey=012345678901234567890123456789123456&" +
          "activity=http%3A%2F%2Ftest.host%2Fsequences%2F1&" +
          "resourceUrl=http%3A%2F%2Ftest.host%2Fsequences%2F1&" +
          "activityIndex=0"
        )
      end
    end

    describe "when interactive is provided" do
      let(:mw_interactive) { FactoryBot.create(:mw_interactive, id: 123) }

      it "adds iframeQuestionId param" do
        expect(ReportService::report_url(run, activity, nil, mw_interactive)).to eq(
          "https://portal-report.concord.org/branch/master/index.html?" +
          "firebase-app=report-service-dev&" +
          "sourceKey=authoring.test.concord.org&" +
          "runKey=012345678901234567890123456789123456&" +
          "activity=http%3A%2F%2Ftest.host%2Factivities%2F23&" +
          "resourceUrl=http%3A%2F%2Ftest.host%2Factivities%2F23&" +
          "iframeQuestionId=mw_interactive_123"
        )
      end
    end
  end
end
