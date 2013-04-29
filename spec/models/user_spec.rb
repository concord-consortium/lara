require 'spec_helper'
require "cancan/matchers"

describe User do
  # Tests User authorization for various actions.
  describe 'abilities' do
    subject  { ability }
    let (:ability) { Ability.new(user) }
    let (:user) { nil }
    context 'when is an administrator' do
      let (:user) { FactoryGirl.build(:admin) }

      it { should be_able_to(:manage, User) }
      it { should be_able_to(:manage, LightweightActivity) }
      it { should be_able_to(:manage, InteractivePage) }
    end

    context 'when is an author' do
      let (:user) { FactoryGirl.build(:author) }
      let (:other_user) { FactoryGirl.build(:author) }
      let (:self_activity) do
        act = FactoryGirl.create(:activity)
        act.user = user
        act.save
        act
      end
      let (:other_activity) do
        oa = FactoryGirl.create(:public_activity)
        oa.user = other_user
        oa.pages << FactoryGirl.create(:page)
        oa.save
        oa
      end

      it { should be_able_to(:create, LightweightActivity) }
      it { should be_able_to(:create, InteractivePage) }
      # Can edit activities they own
      it { should be_able_to(:update, self_activity) }
      it { should_not be_able_to(:update, other_activity) }
      it { should be_able_to(:read, other_activity) }
      it { should be_able_to(:read, other_activity.pages.first) }
    end

    context 'when is a user' do
      pending 'currently same as anonymous'
    end

    context 'when is anonymous' do
      let (:user) { FactoryGirl.build(:user) }
      let (:other_user) { FactoryGirl.build(:author) }
      let (:private_activity) do
        act = FactoryGirl.create(:activity)
        act.user = other_user
        act.save
        act
      end
      let (:public_activity) do
        oa = FactoryGirl.create(:public_activity)
        oa.user = other_user
        oa.pages << FactoryGirl.create(:page)
        oa.save
        oa
      end

      it { should_not be_able_to(:manage, User) }
      it { should_not be_able_to(:update, LightweightActivity) }
      it { should_not be_able_to(:create, LightweightActivity) }
      it { should be_able_to(:read, public_activity) }
      it { should_not be_able_to(:read, private_activity) }
    end
  end

  describe "#find_for_concord_portal_oauth" do
    let(:auth_email)    { "testuser@concord.org" }
    let(:auth_provider) { "portal.concord.org"      }
    let(:auth_uid)      { "23"                   }

    let(:auth) do
      auth_obj = mock(:provider => auth_provider, :uid => auth_uid)
      auth_obj.stub_chain(:info, :email).and_return(auth_email)
      auth_obj
    end

    describe "with matching provider and user" do
      it "should return the matching user" do

        expected = FactoryGirl.create(:user, {
          :provider => auth_provider, :uid => auth_uid})

        User.find_for_concord_portal_oauth(auth).should == expected
      end
    end

    describe "with matching email address and no provider" do
      it "should return the found user" do
        expected = FactoryGirl.create(:user,
          { :email => auth_email, :provider => nil, :uid => nil } )
        User.find_for_concord_portal_oauth(auth).should == expected
      end
      it "should update the provider and user to match found" do
        expected = FactoryGirl.create(:user,
          { :email => auth_email, :provider => nil, :uid => nil } )
        found = User.find_for_concord_portal_oauth(auth)
        found.email.should    == expected.email
        found.provider.should == auth.provider
        found.uid.should      == auth.uid
      end
    end

    describe "with matching email address and wrong provider" do
      it "should throw an exception" do
        expected = FactoryGirl.create(:user,
          { :email => auth_email, :provider => 'some other provider', :uid => auth_uid} )
        expect { User.find_for_concord_portal_oauth(auth) }.to raise_error
      end
    end

    describe "with matching email address and wrong uid" do
      it "should throw an excpetion" do
        expected = FactoryGirl.create(:user,
          { :email => auth_email, :provider => auth_provider, :uid => "222" } )
        expect { User.find_for_concord_portal_oauth(auth) }.to raise_error
      end
    end

  end

end
