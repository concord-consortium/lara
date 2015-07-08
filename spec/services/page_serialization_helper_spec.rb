require 'spec_helper'

describe PageSerializationHelper do
  let(:a_stubs)                { {id: 100} }
  let(:b_stubs)                { {id: 101} }
  let(:copy_a_stubs)           { {id: 200} }
  let(:copy_b_stubs)           { {id: 201} }
  let(:original_interactive_a) { mock_model(MwInteractive, a_stubs      )}
  let(:original_interactive_b) { mock_model(MwInteractive, b_stubs      )}
  let(:copy_of_interactive_a)  { mock_model(MwInteractive, copy_a_stubs )}
  let(:copy_of_interactive_b)  { mock_model(MwInteractive, copy_b_stubs )}
  let(:helper)                 { PageSerializationHelper.new }
  describe "#cache_interactive_copy(original_interactive, copy_of_interactive)" do
    it "shouldn't throw an error" do
      helper.cache_interactive_copy(original_interactive_a, copy_of_interactive_a)
    end
  end

  describe "#lookup_new_interactive(original_interactive)" do
    describe "when two interactive copies are mapped" do
      it "shouldn't get mixed up" do
        helper.cache_interactive_copy(original_interactive_a, copy_of_interactive_a)
        helper.cache_interactive_copy(original_interactive_b, copy_of_interactive_b)
        expect(helper.lookup_new_interactive(original_interactive_a)).to eq copy_of_interactive_a
        expect(helper.lookup_new_interactive(original_interactive_b)).to eq copy_of_interactive_b
      end
    end
  end

end
