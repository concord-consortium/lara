require 'spec_helper'

describe Embeddable::ImageQuestion do

  let (:image_question) { FactoryGirl.create(:image_question) }

  it "should create a new instance with default values" do
    image_question.should be_valid
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = { name: image_question.name, prompt: image_question.prompt, bg_source: image_question.bg_source }
      image_question.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      image_question.duplicate.should be_a_new(Embeddable::ImageQuestion).with( name: image_question.name, prompt: image_question.prompt, bg_source: image_question.bg_source )
    end
  end

  describe '#is_shutterbug?' do
    it 'returns true if bg_source is Shutterbug' do
      image_question.is_shutterbug?.should be_true
    end

    it 'returns false otherwise' do
      image_question.bg_source = 'Drawing'
      image_question.is_shutterbug?.should be_false
    end
  end

  describe '#is_drawing?' do
    it 'returns true if bg_source is Drawing' do
      image_question.bg_source = 'Drawing'
      image_question.is_drawing?.should be_true
    end

    it 'returns false otherwise' do
      image_question.is_drawing?.should be_false
    end
  end

  describe '#is_annotation?' do
    it 'returns true if bg_source is an URL' do
      image_question.bg_source = 'http://concord.org'
      # N.B. eventually this should check for an image, not just an URL
      image_question.is_annotation?.should be_true
    end

    it 'returns false otherwise' do
      image_question.is_annotation?.should be_false
    end
  end
end
