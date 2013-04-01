require 'spec_helper'

describe ActivityResponse do
  let (:activity) { FactoryGirl.create(:activity) }
  let (:response) { 
    r = FactoryGirl.create(:activity_response)
    r.activity = activity
    r
  }
  let (:user) { FactoryGirl.create(:user) }

  describe 'validation' do
    it 'ensures session keys are 16 characters' do
      response.key = 'short'
      response.should_not be_valid
      response.key = 'thiskeyistoolongtobevalid'
      response.should_not be_valid
      response.key = '1234567890123456'
      response.should be_valid
    end

    it 'ensures session keys only have letters and numbers' do
      response.key = 'ABCDEabcde123456'
      response.should be_valid
      response.key = 'ABCD/abcd-12345;'
      response.should_not be_valid
      response.key = 'abcd ABCD_1234--'
      response.should_not be_valid
    end
  end

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
      response.should be_valid # Validation triggers the key generation
      response.key.should_not be_nil
      response.should be_valid
    end
  end

  describe '#to_json' do
    it 'contains the proper keys and values' do
      json_blob = response.to_json(:methods => [:last_page, :storage_keys])
      json_blob.should match /activity_id/
      json_blob.should match /last_page/
      json_blob.should match /storage_keys/
      json_blob.should match /"key":"#{response.key}",/
      json_blob.should match /responses/
      # {
      # activity_id: 1,
      # last_page: null,
      # storage_keys: []
      # key: "be19b7a04a2ea471",
      # responses: null,
      # }
    end
  end
end
