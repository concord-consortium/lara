require 'spec_helper'

describe DashboardToc do
  before(:each) do
    activity.reload #assocaiate the activity with the sequence
  end

  let(:solo_activity)   { FactoryGirl.create(:activity_with_pages, name: 'solo act') }
  let(:activity)        { FactoryGirl.create(:activity, name: 'sequence act') }
  let(:activities)      { [activity] }
  let(:seq)             { FactoryGirl.create(:sequence, title: 'sequence', lightweight_activities: activities) }
  let(:remote_endpoint) { nil }

  describe "when created by an activity not part of a sequence" do
    let(:dashboard_toc) { DashboardToc.new(solo_activity)}
    it "should create a wrapping sequence" do
      expected = {
          name: solo_activity.name
      }
      expect(dashboard_toc.to_hash).to include(expected)
    end
    it "that contains the activities" do
      expect(dashboard_toc.to_hash).to have_key(:activities)
    end
    describe "the activity hash" do
      let(:activity_hash) { dashboard_toc.to_hash()[:activities][0]}
      it "it should have a name" do
        expect(activity_hash).to have_key(:name)
      end
      it "it should have a name" do
        expect(activity_hash).to have_key(:name)
      end
    end

  end

  describe "when created by an activity in a sequence" do
    let(:dashboard_toc) { DashboardToc.new(seq)}
    it "use the activities sequence" do
      expected = {
          name: seq.title
      }
      expect(dashboard_toc.to_hash).to include(expected)
      expect(dashboard_toc.to_hash).to have_key(:activities)
    end
    describe "when the sequence has no activities" do
      let(:activities) { [] }
      it "should still work sort of" do
        expected = {
            name: seq.title
        }
        expect(dashboard_toc.to_hash).to include(expected)
        expect(dashboard_toc.to_hash).to have_key(:activities)
      end
    end
  end
end
