require "spec_helper"

describe LightweightActivityHelper do
  let(:activity)     { FactoryGirl.create(:activity, id: 23, name: "Test Activity") }
  let(:activity_player_activity)     { FactoryGirl.create(:activity, id: 23, name: "Test Activity", runtime: "Activity Player") }
  let(:sequence)     { FactoryGirl.create(:sequence, id: 1, title: "Test Sequence", lightweight_activities: [activity])}
  let(:user)         { FactoryGirl.create(:user) }
  let(:sequence_run) { FactoryGirl.create(:sequence_run, sequence_id: sequence.id, user_id: user.id) }
  let(:run)          { FactoryGirl.create(:run, {key: "012345678901234567890123456789123456", sequence_run: sequence_run, activity: activity, user: user})}
  let(:sequence_path_with_run){ "/sequences/1/activities/23/012345678901234567890123456789123456" }
  let(:sequence_path){ "/sequences/1/activities/23" }
  let(:path_no_run)  { "/activities/23" }

  subject { helper.runnable_activity_path(activity) }

  describe "#runnable_activity_path" do
    describe "with a sequence and sequence run" do
      it "should use the sequence with run path" do
        assign(:run, run)
        assign(:sequence, sequence)
        assign(:sequence_run, sequence_run)
        expect(subject).to eql(sequence_path_with_run)
      end
    end
    describe "with a sequence" do
      it "should use the sequence path" do
        assign(:sequence, sequence)
        expect(subject).to eql(sequence_path)
      end
    end
    describe "without anything" do
      it "should just use the activity path" do
        expect(subject).to eql(path_no_run)
      end
    end
  end

  describe "#activity_player_conversion_url" do
    before(:each) do
      @lara_root = "https://lara.fake"
      @template = "https://lara.fake/api/activities/3.json"
      allow(ENV).to receive(:[]).with("CONVERSION_SCRIPT_URL").and_return("https://test.fake?lara_root=#{@lara_root}&template=#{@template}")
    end
    describe "with an activity" do
      it "should return a URI containing the required params" do
        conversion_url = activity_player_conversion_url(activity)
        uri = URI.parse(conversion_url)
        query = Rack::Utils.parse_query(uri.query)
        expect(query["lara_resource"]).to end_with("activities/#{activity.id}.json")
        expect(query["lara_root"]).to eq(@lara_root)
        expect(query["template"]).to eq(@template)
        expect(query["resource_name"]).to eq("Test Activity")
      end
    end
    describe "with a sequence" do
      it "should return a URI containing the required params" do
        conversion_url = activity_player_conversion_url(sequence)
        uri = URI.parse(conversion_url)
        query = Rack::Utils.parse_query(uri.query)
        expect(query["lara_resource"]).to end_with("sequences/#{sequence.id}.json")
        expect(query["lara_root"]).to eq(@lara_root)
        expect(query["template"]).to eq(@template)
        expect(query["resource_name"]).to eq("Test Sequence")
      end
    end
  end

  describe "#activity_preview_options" do
    describe "with an activity" do
      it "should return a list of preview options" do
        preview_options = helper.activity_preview_options(activity)
        expect(preview_options["Select an option..."]).to eq("")
      end
    end
  end

  describe "#itsi_preview_url" do
  context "with an activity player runtime preview" do
    it "returns an activity player url" do
      url = "https://activity-player.concord.org/branch/master" +
        "?activity=http%3A%2F%2Ftest.host%2Fapi%2Fv1%2Factivities%2F#{activity_player_activity.id}.json&preview"
      expect(helper.itsi_preview_url(activity_player_activity)).to eq(url)
    end
  end
  context "with a LARA runtime preview" do
    it "returns a LARA url" do
      expect(helper.itsi_preview_url(activity)).to eq("/activities/#{activity.id}/preview")
    end
  end
end

  describe "#runtime_url" do
    context "with an activity player runtime" do
      it "returns an activity player url" do
        url = "https://activity-player.concord.org/branch/master" +
          "?activity=http%3A%2F%2Ftest.host%2Fapi%2Fv1%2Factivities%2F#{activity_player_activity.id}.json&preview"
        expect(helper.runtime_url(activity_player_activity)).to eq(url)
      end
    end
    context "with a LARA runtime" do
      it "returns a LARA url" do
        expect(helper.runtime_url(activity)).to eq("/activities/#{activity.id}")
      end
    end
  end
end
