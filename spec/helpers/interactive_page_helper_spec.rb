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

  describe "#show_labbook_under_interactive?" do
    let(:run)            { double("run") }
    let(:interactive)    { double("interactive") }
    let(:labbook)        { double("labbook") }
    let(:labbook_answer) { double("labbook_answer") }
    let(:fake_finder)    { double("finder", find_answer: finder_return) }
    let(:finder_return)  { false }

    before :each do
      allow(Embeddable::AnswerFinder).to receive(:new).and_return(fake_finder)
    end
    describe "When not configured to show the labbook under an interactive" do
      it "should always return false" do
        expect(helper.show_labbook_under_interactive?(run,interactive)).to be false
      end
    end

    describe "When configured to show the labbook under the interactive" do
      before :each do
        assign(:labbook_is_under_interactive, true)
      end

      describe "When the interactive doesn't have a lab book" do
        let(:interactive) { double("interactive", {labbook: nil}) }
        it "should be false" do
          expect(helper.show_labbook_under_interactive?(run,interactive)).to be false
        end
      end

      describe "When the interactive does have an associated lab book" do
        let(:finder_return) { labbook_answer }
        describe "When the interactive supports snapshots" do
          let(:interactive)   { double("interactive", {labbook: labbook, no_snapshots: false}) }
          it "should return the labbook" do
            expect(helper.show_labbook_under_interactive?(run,interactive)).to be labbook_answer
          end
        end
        describe "When the interactive does not support snapshots" do
          let(:interactive)   { double("interactive", {labbook: labbook, no_snapshots: true}) }
          it "should not return the labbook" do
            expect(helper.show_labbook_under_interactive?(run,interactive)).to be false
          end
        end
      end
    end
  end

  describe "#show_labbook_in_assessment_block?" do
    let(:question)    { nil }
    let(:interactive) { nil }
    let(:answer)      { double("answer", question: question) }
    subject           { helper.show_labbook_in_assessment_block?(answer) }

    describe "when the embeddable isn't a labbook" do
      let(:question)  { double "not a labbook" }
      it "should always return false" do
        expect(subject).to be false
      end
    end

    describe "when the embeddable is a labook answer" do
      let(:question)  { Embeddable::Labbook.new(interactive: interactive)}
      describe "when the page isn't cofigured to show the labook under the interactive" do
        it "should should show the labbook in the questions section" do
          expect(subject).to be false
        end
      end

      describe "when the page is configured to show the labbook under the interactive" do
        before :each do
          assign(:labbook_is_under_interactive, true)
        end
        describe "When the Labbook doesn't have an interactive" do
          it "should show the labbook in the assessment section" do
            expect(subject).to be false
          end
        end
        describe "When the labbook does belong to an interactive" do
          let(:interactive) { mock_model(MwInteractive, {}) }
          it "should hide the labbook from the assessment section" do
            expect(subject).to be true
          end
        end

      end
    end
  end

  # def render_interactive(interactive)
  describe "render_interactive" do
    let(:interactive)  { mock_model(MwInteractive) }
    let(:partial_name) { "mw_interactives/show"}
    let(:locals)       { { interactive: interactive} }
    let(:expected_args){ hash_including({partial: partial_name,locals:locals}) }

    it "should render the correct parital" do
      expect(helper).to receive(:render).with(expected_args)
      helper.render_interactive(interactive)
    end
  end

end
