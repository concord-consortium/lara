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
          InteractiveRunState.count.should eql 0
          created = InteractiveRunState.by_run_and_interactive(run,interactive)
          InteractiveRunState.count.should eql 1
          created.run.should eq run
          created.interactive.should eq interactive
        end
      end
      describe "when a interactiveRunState does exists" do
        let(:previously_created) { InteractiveRunState.by_run_and_interactive(run,interactive) }
        it "should return the previously created interactiveRunState" do
          make previously_created
          found = InteractiveRunState.by_run_and_interactive(run,interactive)
          found.should eq previously_created
          another = InteractiveRunState.by_run_and_interactive(run,interactive)
          another.should eq previously_created
          InteractiveRunState.count.should eq 1
        end
      end
    end
  end

  describe 'instance methods' do
  end

end