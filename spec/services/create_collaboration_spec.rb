require 'spec_helper'

describe CreateCollaboration do
  let(:user)     { FactoryGirl.create(:user) }
  let(:collaboration_endpoint_url) { "http://portal.concord.org/collaborations/123" }
  let(:collaboration_params) do
    [
      {
        name: "Foo Bar",
        email: user.email,
        access_token: "auth_token_1",
        learner_id: 101,
        endpoint_url: "http://portal.concord.org/dataservice/101"
      },
      {
        name: "Bar Foo",
        email: "barfoo@bar.foo",
        access_token: "auth_token_2",
        learner_id: 202,
        endpoint_url: "http://portal.concord.org/dataservice/202"
      }
    ]
  end

  before(:each) do
    stub_request(:get, collaboration_endpoint_url).to_return(
      :status => 200,
      :body => collaboration_params.to_json, :headers => {}
    )
  end

  describe "service call" do
    # Obviously it should work only after create collaboration service is called.
    let(:new_user) { User.find_by_email(collaboration_params[1][:email]) }
    let(:material) { FactoryGirl.create(:activity) }

    before(:each) do
      create_collaboration = CreateCollaboration.new(collaboration_endpoint_url, user, material)
      create_collaboration.call
    end

    it "should create new collaboration run" do
      CollaborationRun.count.should == 1
    end

    describe "when an activity is provided as a material" do
      it "should create new run for each user" do
        cr = CollaborationRun.first
        cr.runs.count.should == 2
      end
    end

    describe "when a sequence is provided as a material" do
      let(:material) {
        s = FactoryGirl.create(:sequence)
        s.activities << FactoryGirl.create(:activity)
        s.activities << FactoryGirl.create(:activity)
        s.activities << FactoryGirl.create(:activity)
        s
      }
      it "should create new runs for each user and each activity" do
        cr = CollaborationRun.first
        # 2 users x 3 activities
        cr.runs.count.should == 6
      end
    end

    it "should create new users if they didn't exist before" do
      User.exists?(email: collaboration_params[1][:email]).should == true
    end

    it "should overwrite auth_tokens of all listed collaborators" do
      user.authentication_token.should == collaboration_params[0][:access_token]
      new_user.authentication_token.should == collaboration_params[1][:access_token]
    end
  end

end
