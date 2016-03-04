require 'spec_helper'

describe Run do
  let(:activity)        { FactoryGirl.create(:activity) }
  let(:seq)             { FactoryGirl.create(:sequence, :lightweight_activities => [activity]) }
  let(:remote_endpoint) { nil }
  let(:run) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.remote_endpoint = remote_endpoint
    r.user = user
    r
  }
  let(:run_in_sequence) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.sequence = seq
    r.remote_endpoint = remote_endpoint
    r.user = user
    r
  }
  let(:user)       { FactoryGirl.create(:user) }
  let(:or_question){ FactoryGirl.create(:or_embeddable) }
  let(:or_answer)  { FactoryGirl.create(:or_answer, { :answer_text => "the answer", :question => or_question }) }
  let(:image_quest){ FactoryGirl.create(:image_question, :prompt => "draw your answer") }
  let(:iq_answer)  { FactoryGirl.create(:image_question_answer,
    { :answer_text => "the image question answer",
      :question => image_quest,
      :image_url => "http://foo.com/bar.jpg" }) }
  let(:a1)         { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_one") }
  let(:a2)         { FactoryGirl.create(:multiple_choice_choice, :choice => "answer_two") }
  let(:mc_question){ FactoryGirl.create(:multiple_choice, :choices => [a1, a2]) }
  let(:mc_answer)  { FactoryGirl.create(:multiple_choice_answer, :answers  => [a1], :question => mc_question) }

  let(:portal_url)            { "http://portal.concord.org" }
  let(:valid_remote_endpoint) { portal_url + "/post/blah" }
  let(:portal_auth)           { Concord::AuthPortal.add("run_spec_test_portal", portal_url, "foo", "secret_key") }

  before(:each) do
    # It triggers Concord::AuthPortal.add(...), so portal is always available.
    portal_auth
  end

  describe 'validation' do
    it 'ensures session keys are 36 characters' do
      run.key = 'short'
      expect(run).not_to be_valid
      run.key = 'thiskeyistoolongtobevalidreallyitisseriouslylongevenforauuidIpromisethisislongerthan36charactersnowaythisisshort'
      expect(run).not_to be_valid
      run.key = '123456789012345678901234567890123456'
      expect(run).to be_valid
    end

    it 'ensures session keys only have hyphens, letters and numbers' do
      run.key = '88e0aff5-db3f-4087-8fda-49ec579980ee'
      expect(run).to be_valid
      run.key = '88e0aff5/db3f-4087-8fda-49ec579980e;'
      expect(run).not_to be_valid
      run.key = '88e0aff5 db3f_4087-8fda-49ec579980ee'
      expect(run).not_to be_valid
    end
  end

  describe "after_create" do
    describe "when there is a remote_endpoint" do
      let(:remote_endpoint) { "blarg" }
      it "increments the portal_run_count on the activity" do
        last_count = activity.portal_run_count
        Run.create(:activity => activity, :remote_endpoint => remote_endpoint)
        expect(activity.reload.portal_run_count).to eq(last_count + 1)
      end
    end
    describe "when there is no remote endpoint" do
      let(:remote_endpoint) { "" }
      it "The portal_run_count on the activity does not increase" do
        last_count = activity.portal_run_count
        Run.create(:activity => activity, :remote_endpoint => remote_endpoint)
        expect(activity.reload.portal_run_count).to eq(last_count)
      end
    end
  end

  describe '#session_guid' do
    it 'generates different hashes for each activity run' do
      first_guid  = run.session_guid
      second_guid = run.session_guid

      expect(first_guid).not_to be === second_guid
    end

    it 'generates different hashes with a user than without' do
      first_guid = run.session_guid
      run.user = user
      with_user_guid = run.session_guid

      expect(with_user_guid).not_to be === first_guid
    end
  end

  describe '#check_key' do
    it 'creates a key for an object where key is nil' do
      run.key = nil
      expect(run.key).to be_nil
      expect(run).to be_valid # Validation triggers the key generation
      expect(run.key).not_to be_nil
      expect(run).to be_valid
    end
  end

  describe "#last_page" do
    it "should remember the last page set by the controller" do
      expect(run.page).to be_nil
      page = FactoryGirl.create(:page)
      run.page = page
      run.save
      run.reload
      expect(run.last_page).to eq(page)
    end
  end

  describe "#set_last_page" do
    let(:page) { FactoryGirl.create(:page) }

    it "should set the last page" do
      run.set_last_page(page)
      expect(run.last_page).to eql(page)
    end

    describe "when user runs activity with collaborators" do
      include_context "collaboration run"
      before(:each) do
        setup_collaboration_run
      end

      it "should copy last page to all the related runs" do
        run1.set_last_page(page)
        run2.reload
        run3.reload
        expect(run1.last_page).to eql(page)
        expect(run2.last_page).to eql(page)
        expect(run3.last_page).to eql(page)
      end
    end
  end

  describe '#clear_answers' do
    before(:each) do
      # Add answers
      run.open_response_answers << or_answer
      run.multiple_choice_answers << mc_answer
      or_answer.mark_clean
      mc_answer.mark_clean
    end

    it 'removes all answers from the run' do
      expect(run.answers.length).to eq(2)
      run.clear_answers
      expect(run.reload.answers.length).to eq(0)
    end
  end

  describe '#get_authorization_provider' do
    it 'returns a string designating the authorization provider for its endpoint' do
      skip "Set environment variables for testing"
      run.remote_endpoint = 'http://localhost:9000/data_service/1'
      expect(run.get_auth_provider).to eq('LOCAL')
    end

    it 'returns nil when there is no endpoint' do
      expect(run.get_auth_provider).to be_nil
    end
  end

  describe 'dirty bit management' do
    describe '#mark_dirty' do
      it 'sets is_dirty bit to true' do
        run.mark_dirty
        expect(run.reload.is_dirty).to be_truthy
      end
    end

    describe '#mark_clean' do
      it 'sets is_dirty to false' do
        run.mark_clean
        expect(run.reload.is_dirty).to be_falsey
      end
    end

    describe '#dirty?' do
      it 'returns true when is_dirty is true' do
        run.mark_dirty
        expect(run.dirty?).to be_truthy
      end

      it 'returns false when is_dirty is false' do
        # Default value is false
        expect(run.dirty?).to be_falsey
      end
    end
  end

  describe '#dirty_answers' do
    describe 'when there are no answers' do
      it 'returns an empty array' do
        expect(run.dirty_answers).to eq([])
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
        expect(run.dirty_answers).to eq([])
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
        expect(run.dirty_answers).to eq([or_answer])
        expect(run.dirty_answers.length).to be(1)
      end
    end
  end

  describe '#set_answers_clean' do
    describe 'when the args are empty' do
      it 'does nothing and returns an empty array' do
        expect(run.set_answers_clean([])).to eq([])
      end
    end

    describe 'when there is an array of answers' do
      let(:mocked_answers){ 5.times.map {|x| double("mock_answer_#{x}")}}
      it 'calls is_dirty=false on each answer in the array' do
        mocked_answers.each do |a|
          expect(a).to receive :mark_clean
        end
        run.set_answers_clean mocked_answers
      end
    end
  end

  describe "self.lookup(key,activity,user=nil,portal,seq_id)" do
    describe "with a key" do
      it "should simply use the key" do
        allow(Run).to receive_messages(:by_key => [run])
        expect(Run.lookup("sdfsdfsdf",activity, user, nil,nil)).to eq(run)
      end
    end

    describe "with a sequence, activity and user" do
      it "should return the run with our user, activity, and sequence" do
        found = Run.lookup(nil,activity,user,nil,seq.id)
        expect(run_in_sequence.sequence).to eq(found.sequence)
        expect(run_in_sequence.user).to eq(found.user)
        expect(run_in_sequence.activity).to eq(found.activity)
      end
    end
    describe "without a key" do
      describe "with no user" do
        it "should create a new run" do
          expect(Run).to receive(:create).and_return(run)
          expect(Run.lookup(nil,activity,nil,nil,nil)).to eq(run)
        end
      end

      describe "with no endpoint" do

        describe "with an existing user" do
          describe "when the user has run it before" do
            it "should find the existing users run for the activity" do
              expect(Run).to receive(:find)
                .with(:first, :conditions =>
                  hash_including(:user_id => user.id, :activity_id => activity.id))
                .and_return(run)
              expect(Run.lookup(nil,activity,user,nil,nil)).to eq(run)
            end
          end

          describe "when this is the first time for the user" do
            it "should create a new run for the user and activity" do
              expect(Run).to receive(:find)
                .with(:first, :conditions =>
                  hash_including(:user_id => user.id, :activity_id => activity.id))
                .and_return(nil)
              expect(Run).to receive(:create).and_return(run)
              expect(Run.lookup(nil,activity,user,nil,nil)).to eq(run)
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
          expect(Run).to receive(:find)
            .with(:first, :conditions =>
              hash_including(
                :user_id => user.id,
                :activity_id => activity.id,
                :remote_endpoint => remote.remote_endpoint,
                :remote_id => remote.remote_id
            ))
            .and_return(run)
          expect(Run.lookup(nil,activity, user, remote,nil)).to eq(run)
        end
      end
    end
  end

  describe "#increment_run_count" do
    describe "when unset"  do
      it "should set the runcount to 1" do
        run.increment_run_count!
        run.reload
        expect(run.run_count).to eq(1)
      end
    describe "when set to 1"
      it "should set the runcount to 2" do
        run.run_count = 1
        run.save
        run.increment_run_count!
        run.reload
        expect(run.run_count).to eq(2)
      end
    end
  end

  describe "#has_been_run" do
    describe "when the runcount is 0" do
      it "should return false, indicating it hasn't been run" do
        run.run_count=0
        expect(run.has_been_run).to be_falsey
      end
    end
    describe "when the runcount is nil" do
      it "should return false, indicating it hasn't been run" do
        run.run_count=nil
        expect(run.has_been_run).to be_falsey
      end
    end
    describe "when the runcount is more than zero" do
      it "should return true, indicating it has been run" do
        run.run_count=1
        expect(run.has_been_run).to be_truthy
      end
    end
  end

  describe 'posting to portal' do
    let(:one_expected) { '[{ "type": "open_response", "question_id": "' + or_question.id.to_s + '", "answer": "' + or_answer.answer_text + '", "is_final": ' + or_answer.is_final.to_s + ' }]' }
    let(:all_expected) do
      [
        {
          "type" => "open_response",
          "question_id" => or_question.id.to_s,
          "answer" => or_answer.answer_text,
          "is_final" => or_answer.is_final
        },
        {
          "type" => "multiple_choice",
          "question_id" => mc_question.id.to_s,
          "answer_ids" => [ a1.id.to_s],
          "answer_texts" => [ a1.choice],
          "is_final" => mc_answer.is_final
        },
        {
          "type" => "image_question",
          "question_id" => iq_answer.question.id.to_s,
          "answer" => iq_answer.answer_text,
          "is_final" => iq_answer.is_final,
          "image_url" => iq_answer.annotated_image_url
        },
      ].to_json
    end

    describe '#all_responses_for_portal' do
      it 'matches the expected JSON for all responses' do
        run.open_response_answers << or_answer
        run.multiple_choice_answers << mc_answer
        run.image_question_answers << iq_answer
        expect(JSON.parse(run.all_responses_for_portal)).to eq(JSON.parse(all_expected))
      end
    end

    describe "#send_to_portal" do
      describe "when there is no remote_endpoint" do
        let(:remote_endpoint) { nil }
        it "no http request is made" do
          expect(HTTParty).not_to receive(:post)
          expect(run.send_to_portal([or_answer,mc_answer])).to be_truthy # Take this out of the queue
        end
      end

      describe "when there are no new answers" do
        let(:remote_endpoint) { nil }
        it "no http request is made" do
          expect(HTTParty).not_to receive(:post)
          expect(run.send_to_portal([])).to be_truthy # Take it out of the queue
        end
      end

      describe "with an endpoint and answers" do
        let(:remote_endpoint) { valid_remote_endpoint }
        describe "with a positive response from the server" do
          it "should be successful" do
            # get the payload from the very first protocol version
            payload = PortalSender::Protocol.instance(remote_endpoint).response_for_portal([or_answer,mc_answer])
            stub_http_request(:post, remote_endpoint).to_return(
              :body   => "OK", # TODO: What returns?
              :status => 200)
            expect(run.send_to_portal([or_answer,mc_answer])).to be_truthy
            expect(WebMock).to have_requested(:post, remote_endpoint).
              with({
                :body => payload,
                :headers => {
                  "Authorization" => portal_auth.auth_token,
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
            # We now expect the error message to include payload information
            expect {run.send_to_portal([or_answer,mc_answer])}.to raise_error Run::PortalUpdateIncomplete
          end
        end
      end
    end


    describe '#submit_dirty_answers' do
      let(:answers) {[]}
      let(:remote_endpoint) { valid_remote_endpoint }
      let(:result_status)   { 200 }
      before(:each) do
        stub_http_request(:post, remote_endpoint).to_return(
          :body   => "OK", # TODO: What returns?
          :status => result_status)
        allow(run).to receive_messages(:answers => answers)
        run.mark_dirty
      end
      describe 'when there are no dirty answers' do
        it 'does nothing and returns true' do
          allow(run).to receive_messages(:answers => answers)
          expect(run.submit_dirty_answers).to be_truthy
        end
      end

      describe 'when there are dirty answers' do
        let(:answers) do
          answers = []
          5.times.map do |i|
            q = FactoryGirl.create(:image_question_answer, :run => run, :question => FactoryGirl.create(:image_question))
            q.mark_dirty
            answers << q
          end
          answers
        end

        describe "when the portal answers positively" do
          let(:result_status) { 200 }

          it "calls send_to_portal with the dirty answers as argument" do
            allow(run).to receive_messages(:send_to_portal => true)
            expect(run).to receive(:send_to_portal).with(answers)
            expect(run.submit_dirty_answers).to be_truthy
          end

          it "cleans all the answers afer a successful update" do
            run.submit_dirty_answers
            run.answers.each do |a|
              expect(a).not_to be_dirty
            end
          end

          it "marks itself as clean after a successful update" do
            run.submit_dirty_answers
            expect(run).not_to be_dirty
          end

        end

        describe "when the portal answers with an error" do
          let(:result_status) { 500 }

          it "Raises PortalUpdateIncomplete to keep the job in the queue" do
            expect { run.submit_dirty_answers}.to raise_error(Run::PortalUpdateIncomplete)
          end

          it "The run is not cleaned" do
            expect { run.submit_dirty_answers}.to raise_error(Run::PortalUpdateIncomplete)
            expect(run).to be_dirty
          end

          it "doesn't clean any of the answers afer a borked update" do
            expect { run.submit_dirty_answers}.to raise_error(Run::PortalUpdateIncomplete)
            run.answers.each do |a|
              expect(a).to be_dirty
            end
          end
        end

        describe "when there are still dirty answers after the update" do
          before(:each) do
            answers.each do |a|
              expect(a).to receive(:mark_clean).and_return false
            end
            allow(run).to receive_messages(:dirty_answers => answers)
          end

          it "Raises PortalUpdateIncomplete to keep the job in the queue" do
            expect { run.submit_dirty_answers}.to raise_error(Run::PortalUpdateIncomplete)
          end

          it "The run is not cleaned" do
            expect { run.submit_dirty_answers}.to raise_error(Run::PortalUpdateIncomplete)
            expect(run).to be_dirty
          end

          it "doesn't clean any of the answers afer a borked update" do
            expect { run.submit_dirty_answers}.to raise_error(Run::PortalUpdateIncomplete)
            run.answers.each do |a|
              expect(a).to be_dirty
            end
          end
        end
      end
    end
  end

  describe "Functions relating to 'completeness'" do
    subject         { run }
    let(:questions) { [1,2,3]  }
    let(:answers) { [or_answer, mc_answer, iq_answer]  }
    before(:each) do
      allow(activity).to receive(:questions).and_return(questions)
      allow(run).to receive(:answers).and_return(answers)
    end

    describe "#num_questions" do
      describe '#num_questions' do
        subject { super().num_questions }
        it { is_expected.to eq 3}
      end
    end

    describe "With three answers" do
      let(:answers) { [or_answer, mc_answer, iq_answer]  }

      describe '#num_answers' do
        subject { super().num_answers }
        it { is_expected.to eq 3         }
      end
      it                     { is_expected.to be_completed }

      describe '#percent_complete' do
        subject { super().percent_complete }
        it { is_expected.to eq 100       }
      end
    end

    describe "With two answers" do
      let(:answers) { [or_answer, mc_answer]  }

      describe '#num_answers' do
        subject { super().num_answers }
        it { is_expected.to eq 2                    }
      end
      it                     { is_expected.not_to be_completed        }

      describe '#percent_complete' do
        subject { super().percent_complete }
        it { is_expected.to be_within(0.1).of(66.6) }
      end
    end
  end
end
