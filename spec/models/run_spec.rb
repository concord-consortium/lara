require 'spec_helper'

describe Run do
  let (:activity) { FactoryGirl.create(:activity) }
  let (:run) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r
  }
  let (:user) { FactoryGirl.create(:user) }

  describe 'validation' do
    it 'ensures session keys are 16 characters' do
      run.key = 'short'
      run.should_not be_valid
      run.key = 'thiskeyistoolongtobevalid'
      run.should_not be_valid
      run.key = '1234567890123456'
      run.should be_valid
    end

    it 'ensures session keys only have letters and numbers' do
      run.key = 'ABCDEabcde123456'
      run.should be_valid
      run.key = 'ABCD/abcd-12345;'
      run.should_not be_valid
      run.key = 'abcd ABCD_1234--'
      run.should_not be_valid
    end
  end

  describe '#session_guid' do
    it 'generates different hashes for each activity run' do
      first_guid  = run.session_guid
      second_guid = run.session_guid

      first_guid.should_not === second_guid
    end

    it 'generates different hashes with a user than without' do
      first_guid = run.session_guid
      run.user = user
      with_user_guid = run.session_guid

      with_user_guid.should_not === first_guid
    end

  end

  describe '#check_key' do
    it 'creates a key for an object where key is nil' do
      run.key = nil
      run.key.should be_nil
      run.should be_valid # Validation triggers the key generation
      run.key.should_not be_nil
      run.should be_valid
    end
  end

  describe "#last_page" do
    it "should default to the first page" do
      activity.stub!(:pages => [:a,:b,:c])
      run.page.should be_nil
      run.last_page.should == :a
    end
    it "should remember the last page set by the controller" do
      run.page.should be_nil
      page = FactoryGirl.create(:page)
      run.page = page
      run.save
      run.reload
      run.last_page.should == page
    end
  end


  describe "self.lookup(key,activity,user=nil,remote_id=nil)" do
    describe "with a key" do
      it "should simply use the key" do
        Run.stub!(:by_key => [run])
        Run.lookup("sdfsdfsdf",nil,nil,nil).should == run
      end
    end

    describe "without a key" do
      describe "with no user" do
        it "should create a new run" do
          Run.should_receive(:create).and_return(run)
          Run.lookup(nil,activity,nil,nil).should == run
        end
      end

      describe "with no remote_id" do

        describe "with an existing user" do
          describe "when the user has run it before" do
            it "should find the existing users run for the activity" do
              Run.should_receive(:find)
                .with(:first, :conditions =>
                  hash_including(:user_id => user.id, :activity_id => activity.id))
                .and_return(run)
              Run.lookup(nil,activity,user,nil).should == run
            end
          end

          describe "when this is the first time for the user" do
            it "should create a new run for the user and activity" do
              Run.should_receive(:find)
                .with(:first, :conditions =>
                  hash_including(:user_id => user.id, :activity_id => activity.id))
                .and_return(nil)
              Run.should_receive(:create).and_return(run)
              Run.lookup(nil,activity,user,nil).should == run
            end
          end
        end
      end
    end
  end

  describe '#to_json' do
    it 'contains the proper keys and values' do
      json_blob = run.to_json(:methods => [:last_page, :storage_keys])
      json_blob.should match /activity_id/
      json_blob.should match /last_page/
      json_blob.should match /storage_keys/
      json_blob.should match /"key":"#{run.key}",/
      json_blob.should match /run_count/
      # {
      # activity_id: 1,
      # last_page: null,
      # storage_keys: []
      # key: "be19b7a04a2ea471",
      # run_count: null,
      # }
    end
  end
end
