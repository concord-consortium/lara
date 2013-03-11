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
end
