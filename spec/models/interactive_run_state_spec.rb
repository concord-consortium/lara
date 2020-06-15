require 'spec_helper'

def make(thing); end

describe InteractiveRunState do
  let(:activity)        { FactoryGirl.create(:activity)       }
  let(:interactive)     { FactoryGirl.create(:mw_interactive) }
  let(:user)            { FactoryGirl.create(:user)           }
  let(:run)             { FactoryGirl.create(:run, {activity: activity, user: user})}

  describe 'class methods' do
    describe "InteractiveRunState#generate_key" do
      it "should generate be a random non-nil 20 hex digit key" do
        expect(InteractiveRunState.generate_key).to_not eq InteractiveRunState.generate_key
        expect(InteractiveRunState.generate_key).to_not be_nil
        expect(InteractiveRunState.generate_key.length).to eq 40 # 20 hex digits = 40 chars
      end
    end
    describe "InteractiveRunState#by_run_and_interactive" do
      describe "when no existing interactiveRunState exists" do
        it "should create an interactiveRunState for the interactive" do
          expect(InteractiveRunState.count).to eql 0
          created = InteractiveRunState.by_run_and_interactive(run,interactive)
          expect(InteractiveRunState.count).to eql 1
          expect(created.run).to eq run
          expect(created.interactive).to eq interactive
        end
      end
      describe "when a interactiveRunState does exists" do
        let(:previously_created) { InteractiveRunState.by_run_and_interactive(run,interactive) }
        it "should return the previously created interactiveRunState" do
          make previously_created
          found = InteractiveRunState.by_run_and_interactive(run,interactive)
          expect(found).to eq previously_created
          another = InteractiveRunState.by_run_and_interactive(run,interactive)
          expect(another).to eq previously_created
          expect(InteractiveRunState.count).to eq 1
        end
      end
    end
  end

  describe "instance methods" do
    describe "to_runtime_json" do
      let(:run_data) {'{"second": 2}"'}
      let(:host) { "test.authoring.org" }
      let(:protocol) { "https" }
      let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data)}
      let(:result_hash) { JSON.parse(interactive_run_state.to_runtime_json(protocol, host)) }

      it "should have a run_remote_endpoint" do
        expect(result_hash).to have_key "run_remote_endpoint"
      end

      describe "when the interactive run state has no linked interactive" do
        it "should return the raw_data" do
          expect(result_hash["raw_data"]).to eql run_data
        end
        it "should not have any linked state" do
          expect(result_hash["linked_state"]).to be_nil
          expect(result_hash["has_linked_interactive"]).to eql false
        end
      end

      describe "when the interactive has a linked interactive but the linked interactive has no state" do
        let(:linked_interactive) { FactoryGirl.create(:mw_interactive)}
        let(:interactive)        { FactoryGirl.create(:mw_interactive, {linked_interactive_id: linked_interactive.id})}

        it "should return the raw_data" do
          expect(result_hash["raw_data"]).to eql run_data
        end
        it "should indicate there is a linked interactive" do
          expect(result_hash["has_linked_interactive"]).to eql true
        end
        it "should return a nil linked run state" do
          expect(result_hash["linked_state"]).to be_nil
        end
      end

      describe "when the interactive run state has a linked interactive" do
        let(:linked_run_data)    {'{"first": 1}"'}
        let(:linked_interactive) { FactoryGirl.create(:mw_interactive)}
        let(:linked_run_state)   { InteractiveRunState.create(run: run, interactive: linked_interactive, raw_data: linked_run_data)}
        let(:interactive)        { FactoryGirl.create(:mw_interactive, {linked_interactive_id: linked_interactive.id})}

        before(:each) do
          make linked_run_state
        end

        it "should return the raw_data" do
          expect(result_hash["raw_data"]).to eql run_data
        end
        it "should also include linked state" do
          expect(result_hash["linked_state"]).to eql linked_run_data
          expect(result_hash["has_linked_interactive"]).to eql true
        end

        describe "when the linked interactive is through a sequence run" do
          let(:sequence_run)       { FactoryGirl.create(:sequence_run)}
          let(:run)                { FactoryGirl.create(:run, {sequence_run: sequence_run, activity: activity, user: user})}
          let(:run2)               { FactoryGirl.create(:run, {sequence_run: sequence_run, activity: activity2, user: user})}
          let(:linked_run_data)    {'{"first": 1}"'}
          let(:linked_run_state)   { InteractiveRunState.create(run: run2, interactive: linked_interactive, raw_data: linked_run_data)}
          let(:activity2  )        { FactoryGirl.create(:activity)}
          it "should return the raw_data" do
            expect(result_hash["raw_data"]).to eql run_data
          end
          it "should also include linked state" do
            expect(result_hash["linked_state"]).to eql linked_run_data
          end
        end
      end

      describe "when the interactive run state has a linked interactives chain and the previous interactive doesn't have a state" do
        let(:run_data_1)    {'{"first": 1}"'}
        let(:interactive_1) { FactoryGirl.create(:mw_interactive)}
        let(:run_state_1)   { InteractiveRunState.create(run: run, interactive: interactive_1, raw_data: run_data_1)}
        let(:interactive_2) { FactoryGirl.create(:mw_interactive, {linked_interactive_id: interactive_1.id})}
        let(:interactive) { FactoryGirl.create(:mw_interactive, {linked_interactive_id: interactive_2.id})}

        before(:each) do
          make run_state_1
        end

        it "should return the raw_data" do
          expect(result_hash["raw_data"]).to eql run_data
        end
        it "should also include linked state" do
          expect(result_hash["linked_state"]).to eql run_data_1
          expect(result_hash["has_linked_interactive"]).to eql true
        end
      end
    end

    # this hash is depended on by the Portal
    describe "portal_hash" do
      subject { interactive_run_state.portal_hash }

      describe "when interactive has a report url" do
        let(:run_data) { '{"second": 2, "lara_options": {"reporting_url": "test.com"}}' }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data) }

        describe "when interactive is an instance of MwInteractive" do
          let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: true) }

          it "should provide required set of properties and the question_id should be numeric ID" do
            expect(subject).to include({
              type: "external_link",
              question_type: "iframe interactive", # missing underscore, as that's what Portal actually expects
              question_id: interactive.id.to_s,
              answer: "test.com",
              is_final: false
            })
          end
        end

        describe "when interactive is NOT an instance of MwInteractive" do
          let(:library_interactive) { FactoryGirl.create(:library_interactive, has_report_url: true) }
          let(:interactive) { FactoryGirl.create(:managed_interactive, library_interactive: library_interactive) }

          it "should provide required set of properties and the question_id should be embeddable ID" do
            expect(subject).to include({
              type: "external_link",
              question_type: "iframe interactive", # missing underscore, as that's what Portal actually expects
              question_id: interactive.embeddable_id,
              answer: "test.com",
              is_final: false
            })
          end
        end
      end

      describe "when interactive doesn't have a report url" do
        let(:run_data) { '{"someProp": 123}' }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data) }

        describe "when interactive is an instance of MwInteractive" do
          let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: false) }

          it "should provide required set of properties and the question_id should be numeric ID" do
            expect(subject).to include({
              type: "interactive",
              question_id: interactive.id.to_s,
              is_final: false
            })
            expect(JSON.parse(subject[:answer])).to include({
              "version" => 1,
              "mode" => "report",
              "interactiveState" => '{"someProp": 123}'
            })
          end
        end

        describe "when interactive is NOT an instance of MwInteractive" do
          let(:interactive) { FactoryGirl.create(:managed_interactive) }

          it "should provide required set of properties and the question_id should be embeddable ID" do
            expect(subject).to include({
              type: "interactive",
              question_id: interactive.embeddable_id,
              is_final: false
            })
            expect(JSON.parse(subject[:answer])).to include({
              "version" => 1,
              "mode" => "report",
              "interactiveState" => '{"someProp": 123}'
            })
          end
        end
      end

      describe "when interactive run state pretends to be open response answer" do
        let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true) }
        let(:run_data) { JSON({answerType: "open_response_answer", answerText: "Test answer", submitted: true}) }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data) }

        it "should overwrite type and provide supported fields to Portal" do
          expect(subject).to include({
            type: "open_response",
            question_id: "mw_interactive_#{interactive.id.to_s}",
            answer: "Test answer",
            is_final: true
          })
        end
      end

      describe "when interactive run state pretends to be multiple choice answer" do
        let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true) }
        let(:run_data) { JSON({answerType: "multiple_choice_answer", selectedChoiceIds: ["a", "b"], submitted: true}) }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data)}

        it "should overwrite type and provide supported fields to Portal" do
          expect(subject).to include({
            type: "multiple_choice",
            question_id: "mw_interactive_#{interactive.id.to_s}",
            answer_ids: ["a", "b"],
            # answer_texts is not used by portal anymore (even though it's sent in multiple_choice_answer.rb)
            is_final: true
          })
        end
      end
    end

    describe "#report_service_hash" do
      subject { interactive_run_state.report_service_hash }

      describe "when interactive has a report url" do
        # Only when reporting_url is available.
        let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: true) }
        let(:run_data) { '{"second": 2, "lara_options": {"reporting_url": "test.com"}}' }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data) }

        it "should provide required set of properties" do
          expect(subject).to include({
            type: "external_link",
            id: interactive_run_state.answer_id,
            question_type: "iframe_interactive",
            question_id: interactive.embeddable_id,
            answer: "test.com"
          })
        end
      end

      describe "when interactive doesn't have a report url" do
        # Only when reporting_url is available.
        let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true, has_report_url: false) }
        let(:run_data) { '{"someProp": 123}' }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data) }

        it "should provide required set of properties" do
          expect(subject).to include({
            type: "interactive_state",
            id: interactive_run_state.answer_id,
            question_type: "iframe_interactive",
            question_id: interactive.embeddable_id
          })
          expect(JSON.parse(subject[:answer])).to include({
            "version" => 1,
            "mode" => "report",
            "interactiveState" => '{"someProp": 123}'
          })
        end
      end

      describe "when interactive run state pretends to be open response answer" do
        let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true) }
        let(:run_data) { JSON({answerType: "open_response_answer", answerText: "Test answer", submitted: true}) }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data) }

        it "should overwrite type and provide supported fields to Report Service" do
          expect(subject).to include({
            type: "open_response_answer",
            id: interactive_run_state.answer_id,
            question_id: "mw_interactive_#{interactive.id.to_s}",
            question_type: "open_response",
            answer: "Test answer",
            submitted: true
          })
        end
      end

      describe "when interactive run state pretends to be multiple choice answer" do
        let(:interactive) { FactoryGirl.create(:mw_interactive, enable_learner_state: true) }
        let(:run_data) { JSON({answerType: "multiple_choice_answer", selectedChoiceIds: ["a", "b"], submitted: true}) }
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data)}

        it "should overwrite type and provide supported fields to Report Service" do
          expect(subject).to include({
            type: "multiple_choice_answer",
            id: interactive_run_state.answer_id,
            question_id: "mw_interactive_#{interactive.id.to_s}",
            question_type: "multiple_choice",
            answer: { choice_ids: ["a", "b"] },
            submitted: true
          })
        end
      end
    end

    # this key is generated automatically when created
    describe "key" do
      describe "when not manually set" do
        let(:run_data) {'{"second": 2}"'}
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data)}

        it "should be a random non-nil 20 hex digit key" do
          expect(interactive_run_state.key).to_not be_nil
          expect(interactive_run_state.key.length).to eq 40 # 20 hex digits = 40 chars
        end
      end

      describe "when manually set" do
        let(:run_data) {'{"second": 2}"'}
        let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data, key: 'foo')}

        it "should not be overwritten by a generated key" do
          expect(interactive_run_state.key).to eq 'foo'
        end
      end
    end

    describe "#answered?" do
      let(:run_data) { '{"lara_options": {"reporting_url": "http://concord.org"}}' }
      let(:interactive_run_state) { InteractiveRunState.create(interactive: interactive, raw_data: run_data)}

      subject { interactive_run_state }
      it { is_expected.to be_answered }
    end
  end
end
