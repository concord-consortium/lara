require 'spec_helper'

describe "sequence_next_prev buttons" do
  let(:seq_options) {{title: 'Test Sequence', activities_count: 3 }}

  let(:sequence) { FactoryBot.create(:sequence_with_activity, seq_options) }
  let(:prev_act) { sequence.activities[0] }
  let(:activity) { sequence.activities[1] }
  let(:next_act) { sequence.activities[2] }

  describe "when evaluated as part of a sequence" do
    let(:partial_opts) do
      {
        activity: activity,
        sequence: sequence,
        next_href: true,
        last_href: true,
      }
    end

    it "returns navigation links that include sequence paths" do
      assign(:sequence, sequence)
      exp_next="href=\"/sequences/#{sequence.id}/activities/#{next_act.id}"
      exp_prev="href=\"/sequences/#{sequence.id}/activities/#{prev_act.id}"

      render "shared/sequence_next_prev", partial_opts
      expect(rendered).to match(exp_next)
      expect(rendered).to match(exp_prev)
    end
  end

end