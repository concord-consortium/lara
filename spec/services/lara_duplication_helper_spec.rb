require 'spec_helper'

describe LaraDuplicationHelper do
  let(:item) { FactoryBot.create(:open_response) }
  let(:helper) { LaraDuplicationHelper.new }

  describe "#get_copy" do
    it "should return copy of a given item" do
      copy = helper.get_copy(item)
      expect(copy).not_to eq item
    end

    it "subsequent calls should return the same copy object" do
      copy = helper.get_copy(item)
      expect(copy).not_to eq item
      expect(helper.get_copy(item)).to eq copy
    end
  end
end
