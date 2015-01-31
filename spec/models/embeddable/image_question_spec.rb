require 'spec_helper'

describe Embeddable::ImageQuestion do

  let (:image_question) { FactoryGirl.create(:image_question) }

  it "should create a new instance with default values" do
    expect(image_question).to be_valid
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = {
        name: image_question.name,
        prompt: image_question.prompt,
        drawing_prompt: image_question.drawing_prompt,
        bg_source: image_question.bg_source,
        bg_url: image_question.bg_url
      }
      expect(image_question.to_hash).to eq(expected)
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(image_question.duplicate).to be_a_new(Embeddable::ImageQuestion).with( name: image_question.name, prompt: image_question.prompt, drawing_prompt: image_question.drawing_prompt, bg_source: image_question.bg_source, bg_url: image_question.bg_url )
    end
  end

  describe '#is_shutterbug?' do
    it 'returns true if bg_source is Shutterbug' do
      expect(image_question.is_shutterbug?).to be_truthy
    end

    it 'returns false otherwise' do
      image_question.bg_source = 'Drawing'
      expect(image_question.is_shutterbug?).to be_falsey
    end
  end

  describe '#is_drawing?' do
    it 'returns true if bg_source is Drawing' do
      image_question.bg_source = 'Drawing'
      expect(image_question.is_drawing?).to be_truthy
    end

    it 'returns false otherwise' do
      expect(image_question.is_drawing?).to be_falsey
    end
  end
end
