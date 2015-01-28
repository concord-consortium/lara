require 'spec_helper'

def make(thing); end

describe InteractiveRunState do
  let(:activity)        { FactoryGirl.create(:activity)       }
  let(:interactive)     { FactoryGirl.create(:mw_interactive) }
  let(:user)            { FactoryGirl.create(:user)           }
  let(:run) do
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user
    r
  end

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

  describe 'instance methods' do
  end

end