require 'spec_helper'

describe Embeddable::ImageQuestion do
  it_behaves_like "a question"
  it_behaves_like "attached to interactive"

  let (:image_question) { FactoryBot.create(:image_question) }

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
        bg_url: image_question.bg_url,
        is_prediction: image_question.is_prediction,
        is_half_width: image_question.is_half_width,
        give_prediction_feedback: image_question.give_prediction_feedback,
        prediction_feedback: image_question.prediction_feedback,
        is_hidden: image_question.is_hidden,
        hint: image_question.hint
      }
      expect(image_question.to_hash).to eq(expected)
    end
  end

  describe "#export" do
    let(:json){ emb.export.as_json }
    let(:emb) { image_question }
    it 'preserves is_hidden' do
      emb.is_hidden = true
      expect(json['is_hidden']).to eq true
    end
  end

  describe "#portal_hash" do
    it 'returns properties supported by Portal' do
      expect(image_question.portal_hash).to eq(
        type: "image_question",
        id: image_question.id,
        prompt: image_question.prompt,
        drawing_prompt: image_question.drawing_prompt,
        is_required: image_question.is_prediction
      )
    end
  end

  describe "#report_service_hash" do
    it 'returns properties supported by the report service' do
      expect(image_question.report_service_hash).to eq(
        type: "image_question",
        id: "image_question_" + image_question.id.to_s,
        prompt: image_question.prompt,
        drawing_prompt: image_question.drawing_prompt,
        question_number: nil,
        required: image_question.is_prediction
      )
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

  describe "import" do
    let(:json_with_promt){ image_question.export.as_json.symbolize_keys }
    let(:json_without_promt){
      img_ques = image_question.export.as_json.symbolize_keys
      img_ques.except(:prompt)
    }
    it "does not reset the default prompt if there is prompt in the json" do
      new_image_question = Embeddable::ImageQuestion.import(json_with_promt)
      expect(new_image_question.prompt).to eq(image_question.prompt)
    end
    it "resets the default prompt if there is no prompt in the json" do
      new_image_question = Embeddable::ImageQuestion.import(json_without_promt)
      expect(new_image_question.prompt).to eq("")
    end
  end
end
