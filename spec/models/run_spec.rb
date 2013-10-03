require 'spec_helper'

describe Run do
  let (:activity)        { FactoryGirl.create(:activity) }
  let (:remote_endpoint) { nil }
  let (:run) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.remote_endpoint = remote_endpoint
    r.user = user
    r
  }
  let (:user)       { FactoryGirl.create(:user) }
  let (:or_question){ FactoryGirl.create(:or_embeddable) }
  let (:or_answer)  { FactoryGirl.create(:or_answer, { :answer_text => "the answer", :question => or_question }) }
  let (:image_quest){ FactoryGirl.create(:image_question, :prompt => "draw your answer") }
  let (:iq_answer)  { FactoryGirl.create(:image_question_answer,
    { :answer_text => "the image question answer",
      :question => image_quest,
      :image_url => "http://foo.com/bar.jpg" }) }
  let (:a1)         { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_one") }
  let (:a2)         { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_two") }
  let (:mc_question){ FactoryGirl.create(:multiple_choice, :choices => [a1, a2]) }
  let (:mc_answer)  { FactoryGirl.create(:multiple_choice_answer,
                    :answers  => [a1],
                    :question => mc_question)
                  }

  describe 'validation' do
    it 'ensures session keys are 36 characters' do
      run.key = 'short'
      run.should_not be_valid
      run.key = 'thiskeyistoolongtobevalidreallyitisseriouslylongevenforauuidIpromisethisislongerthan36charactersnowaythisisshort'
      run.should_not be_valid
      run.key = '123456789012345678901234567890123456'
      run.should be_valid
    end

    it 'ensures session keys only have hyphens, letters and numbers' do
      run.key = '88e0aff5-db3f-4087-8fda-49ec579980ee'
      run.should be_valid
      run.key = '88e0aff5/db3f-4087-8fda-49ec579980e;'
      run.should_not be_valid
      run.key = '88e0aff5 db3f_4087-8fda-49ec579980ee'
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

  describe 'dirty bit management' do
    describe '#mark_dirty' do
      it 'sets is_dirty bit to true' do
        run.mark_dirty
        run.reload.is_dirty.should be_true
      end
    end

    describe '#mark_clean' do
      it 'sets is_dirty to false' do
        run.mark_clean
        run.reload.is_dirty.should be_false
      end
    end

    describe '#dirty?' do
      it 'returns true when is_dirty is true' do
        run.mark_dirty
        run.dirty?.should be_true
      end

      it 'returns false when is_dirty is false' do
        # Default value is false
        run.dirty?.should be_false
      end
    end
  end

  describe '#dirty_answers' do
    describe 'when there are no answers' do
      it 'returns an empty array' do
        run.dirty_answers.should == []
      end
    end

    describe 'when there are answers, but none are dirty' do
      before(:each) do
        # Add answers
        run.open_response_answers << or_answer
        run.multiple_choice_answers << mc_answer
        or_answer.mark_clean
        mc_answer.mark_clean
      end

      it 'returns an empty array' do
        run.dirty_answers.should == []
      end
    end

    describe 'when there are dirty answers' do
      before(:each) do
        # Add answers
        run.open_response_answers << or_answer
        run.multiple_choice_answers << mc_answer
        mc_answer.mark_clean
      end

      it 'returns an array including only the dirty answers' do
        run.dirty_answers.should == [or_answer]
        run.dirty_answers.length.should be(1)
      end
    end
  end

  describe '#set_answers_clean' do
    describe 'when the args are empty' do
      it 'does nothing and returns nil' do
        pending "Write this test"
      end
    end

    describe 'when there is an array of answers' do
      it 'calls is_dirty=false on each answer in the array' do
        pending "Mock answers and write test to check the mocks"
      end
    end
  end

  describe "self.lookup(key,activity,user=nil,portal)" do
    describe "with a key" do
      it "should simply use the key" do
        Run.stub!(:by_key => [run])
        Run.lookup("sdfsdfsdf",activity, user, nil).should == run
      end
    end

    describe "without a key" do
      describe "with no user" do
        it "should create a new run" do
          Run.should_receive(:create).and_return(run)
          Run.lookup(nil,activity,nil,nil).should == run
        end
      end

      describe "with no endpoint" do

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

      describe "with a remote endpoint" do
        let(:remote) do
          RemotePortal.new({
            externalId: "23",
            returnUrl: "http://foo.bar/",
            domain: "blah"
          })
        end

        it "should find a run by using a remote_endpoint" do
          Run.should_receive(:find)
            .with(:first, :conditions =>
              hash_including(
                :user_id => user.id,
                :activity_id => activity.id,
                :remote_endpoint => remote.remote_endpoint,
                :remote_id => remote.remote_id
            ))
            .and_return(run)
          Run.lookup(nil,activity, user, remote).should == run
        end
      end
    end
  end

  describe "#increment_run_count" do
    describe "when unset"  do
      it "should set the runcount to 1" do
        run.increment_run_count!
        run.reload
        run.run_count.should == 1
      end
    describe "when set to 1"
      it "should set the runcount to 2" do
        run.run_count = 1
        run.save
        run.increment_run_count!
        run.reload
        run.run_count.should == 2
      end
    end
  end

  describe 'posting to portal' do
    let(:one_expected) { '[{ "type": "open_response", "question_id": "' + or_question.id.to_s + '", "answer": "' + or_answer.answer_text + '" }]' }
    let(:all_expected) do
      [
        {
          "type" => "open_response",
          "question_id" => or_question.id.to_s,
          "answer" => or_answer.answer_text
        },
        {
          "type" => "multiple_choice",
          "question_id" => mc_question.id.to_s,
          "answer_ids" => [ a1.id.to_s],
          "answer_texts" => [ a1.choice]
        },
        {
          "type" => "image_question",
          "question_id" => iq_answer.id.to_s,
          "answer" => iq_answer.answer_text,
          "image_url" => iq_answer.image_url,
          "annotation" => nil
        },
      ].to_json
    end

    describe '#response_for_portal' do
      it 'matches the expected JSON for a single specified answer' do
        run.open_response_answers << or_answer
        run.multiple_choice_answers << mc_answer
        run.image_question_answers << iq_answer
        JSON.parse(run.response_for_portal(or_answer)).should == JSON.parse(one_expected)
      end

      it "matches the expected JSON for multiple specified answers" do
        run.open_response_answers << or_answer
        run.multiple_choice_answers << mc_answer
        run.image_question_answers << iq_answer
        JSON.parse(run.response_for_portal([or_answer, mc_answer,iq_answer])).should == JSON.parse(all_expected)
      end
    end

    describe '#all_responses_for_portal' do
      it 'matches the expected JSON for all responses' do
        run.open_response_answers << or_answer
        run.multiple_choice_answers << mc_answer
        run.image_question_answers << iq_answer
        JSON.parse(run.all_responses_for_portal).should == JSON.parse(all_expected)
      end
    end

    describe "#send_to_portal" do
      describe "when there is no remote_endpoint" do
        let(:remote_endpoint) { nil }
        it "no http request is made" do
          HTTParty.should_not_receive(:post)
          run.send_to_portal([or_answer,mc_answer]).should be_false
        end
      end

      describe "when there are no new answers" do
        let(:remote_endpoint) { nil }
        it "no http request is made" do
          HTTParty.should_not_receive(:post)
          run.send_to_portal([]).should be_false
        end
      end

      describe "with an endpoint and answers" do
        let(:remote_endpoint) { "http://portal.concord.org/post/blah" }
        let(:auth_token) { "xyzzy" }
        describe "with a positive response from the server" do
          it "should be successful" do
            payload = run.response_for_portal([or_answer,mc_answer])
            user.stub(:authentication_token => auth_token)
            stub_http_request(:post, remote_endpoint).to_return(
              :body   => "OK", # TODO: What returns?
              :status => 200)
            run.send_to_portal([or_answer,mc_answer]).should be_true
            WebMock.should have_requested(:post, remote_endpoint).
              with({
                :body => payload,
                :headers => {
                  "Authorization" => run.bearer_token,
                  "Content-Type" => 'application/json'
                }
              })
          end
        end
        describe "when the server reports an error" do
          it "should fail" do
            stub_http_request(:post, remote_endpoint).to_return(
              :body   => "boo", # TODO: What returns?
              :status => 503)
            run.send_to_portal([or_answer,mc_answer]).should be_false
          end
        end
      end
    end

    describe '#update_portal' do
      describe 'when dirty? is false' do
        it 'does nothing' do
          pending 'test mocks to ensure nothing happens'
        end
      end

      describe 'when dirty? is true' do
        it 'calls #submit_dirty_answers' do
          pending 'write mock and test'
        end

        it 'checks for more dirty answers' do
          pending 'write mock and test'
        end

        describe 'when #submit_dirty_answers returns false' do
          it 'requeues' do
            pending 'code for enqueueing self'
          end
        end

        describe 'when #submit_dirty_answers returns true but there are still dirty answers (perhaps new ones)' do
          it 'requeues' do
            pending 'code for enqueueing self'
          end
        end
      end
    end

    describe '#submit_dirty_answers' do
      describe 'when there are no dirty answers' do
        it 'does nothing and returns true' do
          pending 'write this test'
        end
      end

      describe 'when there are dirty answers' do
        it 'calls send_to_portal with the dirty answers as argument' do
          pending 'write this test'
        end

        it 'calls set_answers_clean with the dirty answers' do
          pending 'write this test'
        end
      end
    end
  end
end
