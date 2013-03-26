require 'spec_helper'

describe ActivityResponse do
  let (:activity) { FactoryGirl.create(:activity) }
  let (:response) { 
    r = FactoryGirl.create(:activity_response)
    r.activity = activity
    r
  }
  let (:user) { FactoryGirl.create(:user) }

  describe '#session_guid' do
    it 'generates different hashes for each run' do
      first_guid = response.session_guid
      second_guid = response.session_guid

      first_guid.should_not === second_guid
    end

    it 'generates different hashes with a user than without' do
      first_guid = response.session_guid
      with_user_guid = response.session_guid(user)

      with_user_guid.should_not === first_guid
    end
  end

  describe '#check_key' do
    it 'creates a key for an object where key is nil' do
      response.key = nil
      response.key.should be_nil
      response.save
      response.key.should_not be_nil
    end
  end
end
