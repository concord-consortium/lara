require "spec_helper"

describe InteractivePageHelper do

  let(:act_stubs)  {{}}
  let(:page_stubs) {{}}
  let(:sequence_run_stubs) {{}}

  let(:activity)     { mock_model(LightweightActivity, act_stubs) }
  let(:activity_2)   { mock_model(LightweightActivity, act_stubs) }
  let(:page)         { mock_model(InteractivePage, page_stubs)    }
  let(:run)          { mock_model(Run, run_stubs)                 }
  let(:other_run)    { mock_model(Run, other_run_stubs)           }
  let(:sequence_run) { nil }

  let(:run_stubs) do
    {key: "x" * 36,
     activity: activity,
     sequence_run: sequence_run
    }
  end

  let(:other_run_stubs) do
    {key: "y" * 36,
     activity: activity_2
    }
  end
  subject {helper.runnable_activity_page_path(activity,page)}

  describe "#runnable_activity_page_path(activity, page)" do
    describe "without a run" do
      it "should do match a run-free path" do
        expect(subject).to eq("/activities/#{activity.id}/pages/#{page.id}")
      end
    end

    describe "with a run" do
      before(:each) do
        assign(:run, run)
      end
      describe "when the run isn't part of a sequence" do
        it "the link should include a run's key" do
          expect(subject).to eq("/activities/#{activity.id}/pages/#{page.id}/#{run.key}")
        end

        describe "when the run is for a different activity" do
          subject {helper.runnable_activity_page_path(activity_2,page)}
          it " the link should not include the run key" do
            expect(subject).to eq("/activities/#{activity_2.id}/pages/#{page.id}") 
          end
        end
      end

      describe "when the run belongs to a sequence run" do
        let(:sequence_run) { mock_model(SequenceRun, sequence_run_stubs)}
        it "the link should include the run's key" do
          expect(subject).to eq("/activities/#{activity.id}/pages/#{page.id}/#{run.key}")
        end

        describe "when the activity doesn't belong to the run" do
          let(:sequence_run_stubs) {{run_for_activity: nil}}
          subject {helper.runnable_activity_page_path(activity_2,page)}
          it " the link should not include the run key" do
            expect(subject).to eq("/activities/#{activity_2.id}/pages/#{page.id}") 
          end
          
          describe "but if it is part of the same sequence" do
            let(:sequence_run_stubs) {{run_for_activity: other_run}}
            it " the link should include the other run's key" do
              expect(subject).to eq("/activities/#{activity_2.id}/pages/#{page.id}/#{other_run.key}")  
            end
          end
        end
      end
    end
  end

end
