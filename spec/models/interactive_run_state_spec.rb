require 'spec_helper'

def make(thing); end

describe InteractiveRunState do
  let(:activity)        { FactoryGirl.create(:activity)       }
  let(:interactive)     { FactoryGirl.create(:mw_interactive) }
  let(:user)            { FactoryGirl.create(:user)           }
  let(:run)             { FactoryGirl.create(:run, {activity: activity, user: user})}

  describe 'class methods' do
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
      let(:interactive_run_state) { InteractiveRunState.create(run: run, interactive: interactive, raw_data: run_data)}
      let(:result_hash) { JSON.parse(interactive_run_state.to_runtime_json) }
      describe "when the interactice run state has no parent" do
        it "should return the raw_data" do
          expect(result_hash["raw_data"]).to eql run_data
        end
        it "should not have any linked state" do
          expect(result_hash["linked_state"]).to be_nil
        end
      end
      describe "when the interactive run state has a parent" do
        let(:parent_run_data)    {'{"first": 1}"'}
        let(:parent_interactive) { FactoryGirl.create(:mw_interactive)}
        let(:parent_run_state)   { InteractiveRunState.create(run: run, interactive: parent_interactive, raw_data: parent_run_data)}
        let(:interactive)        { FactoryGirl.create(:mw_interactive, {parent_id: parent_interactive.id})}
        describe "when the interactice run state has no parent" do
          it "should return the raw_data" do
            expect(result_hash["raw_data"]).to eql run_data
          end
          it "should also include linked state" do
            make parent_run_state
            expect(result_hash["linked_state"]).to eql parent_run_data
          end
        end
      end
    end

  end
end