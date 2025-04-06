require 'spec_helper'

describe CreateCollaboration do
  let(:user) { FactoryBot.create(:user) }
  let(:collaborators_data_url) { "http://portal.org/collaborations/123" }
  let(:collaboration_params) do
    [
      {
        name: "Foo Bar",
        email: user.email,
        learner_id: 101,
        endpoint_url: "http://portal.concord.org/dataservice/101",
        platform_id: "http://portal.concord.org",
        platform_user_id: "123",
        resource_link_id: "202",
        context_id: "class_hash_123",
        class_info_url: "http://portal.concord.org/class/1"
      },
      {
        name: "Bar Foo",
        email: "barfoo@bar.foo",
        learner_id: 202,
        endpoint_url: "http://portal.concord.org/dataservice/202",
        platform_id: "http://portal.concord.org",
        platform_user_id: "321",
        resource_link_id: "202",
        context_id: "class_hash_123",
        class_info_url: "http://portal.concord.org/class/1"
      }
    ]
  end
  let(:stubbed_content_type) { 'application/json' }
  let(:stubbed_token)        { 'foo'              }
  let(:headers) do
    {
      "Authorization" => stubbed_token,
      "Content-Type"  => stubbed_content_type
    }
  end
  before(:each) do
    allow(Concord::AuthPortal).to receive(:auth_token_for_url).and_return(stubbed_token)
    stub_request(:get, collaborators_data_url).with(headers: headers).to_return(
      status: 200,
      body: collaboration_params.to_json, headers: {}
    )
  end

  describe "service call" do
    # Obviously it should work only after create collaboration service is called.
    let(:new_user) { User.find_by_email(collaboration_params[1][:email]) }
    let(:material) { FactoryBot.create(:activity) }
    let(:create_collaboration) { CreateCollaboration.new(collaborators_data_url, user, material) }

    it "should create new collaboration run" do
      create_collaboration.call
      expect(CollaborationRun.count).to eq(1)
    end

    it "should use the protocol to find the auth_token" do
      expect(Concord::AuthPortal).to receive(:auth_token_for_url).with("http://portal.org")
      create_collaboration.call
    end

    describe "when a https url is used" do
      let(:collaborators_data_url) { "https://portal.org/collaborations/123" }

      it "should pass the https protocol through to find the auth_token" do
        expect(Concord::AuthPortal).to receive(:auth_token_for_url).with("https://portal.org")
        create_collaboration.call
      end
    end

    describe "when an activity is provided as a material" do
      it "should create new run for each user" do
        create_collaboration.call
        cr = CollaborationRun.first
        expect(cr.runs.count).to eq(2)
      end

      it "should save platform info for each run" do
        create_collaboration.call
        cr = CollaborationRun.first
        expect(cr.runs[0].platform_user_id).to eq("123")
        expect(cr.runs[1].platform_user_id).to eq("321")
        cr.runs.each do |run|
          expect(run.platform_id).to eq("http://portal.concord.org")
          expect(run.resource_link_id).to eq("202")
          expect(run.context_id).to eq("class_hash_123")
          expect(run.class_info_url).to eq("http://portal.concord.org/class/1")
        end
      end
    end

    describe "when a sequence is provided as a material" do
      let(:material) {
        s = FactoryBot.create(:sequence)
        s.activities << FactoryBot.create(:activity)
        s.activities << FactoryBot.create(:activity)
        s.activities << FactoryBot.create(:activity)
        s
      }
      it "should create new runs for each user and each activity" do
        create_collaboration.call
        cr = CollaborationRun.first
        # 2 users x 3 activities
        expect(cr.runs.count).to eq(6)
      end

      it "should save platform info for each run" do
        create_collaboration.call
        cr = CollaborationRun.first
        # 2 users x 3 activities
        expect(cr.runs[0].platform_user_id).to eq("123")
        expect(cr.runs[1].platform_user_id).to eq("123")
        expect(cr.runs[2].platform_user_id).to eq("123")
        expect(cr.runs[3].platform_user_id).to eq("321")
        expect(cr.runs[4].platform_user_id).to eq("321")
        expect(cr.runs[5].platform_user_id).to eq("321")
        cr.runs.each do |run|
          expect(run.platform_id).to eq("http://portal.concord.org")
          expect(run.resource_link_id).to eq("202")
          expect(run.context_id).to eq("class_hash_123")
          expect(run.class_info_url).to eq("http://portal.concord.org/class/1")
        end
      end
    end

    it "should create new users if they didn't exist before" do
      create_collaboration.call
      expect(User.exists?(email: collaboration_params[1][:email])).to eq(true)
    end
  end
end
