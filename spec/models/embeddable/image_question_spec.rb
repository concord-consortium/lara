require 'spec_helper'

describe Embeddable::ImageQuestion do

  let (:image_question) { FactoryGirl.create(:image_question) }

  it "should create a new instance with default values" do
    image_question.should be_valid
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = { name: image_question.name, prompt: image_question.prompt }
      image_question.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      image_question.duplicate.should be_a_new(Embeddable::ImageQuestion).with( name: image_question.name, prompt: image_question.prompt )
    end
  end
end
