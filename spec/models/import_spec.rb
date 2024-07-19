require 'spec_helper'
describe Import do

  let (:user) { FactoryGirl.create(:admin) }
  let (:valid_activity_import_v1_json) { File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import_v1.json') }
  let (:valid_activity_import_v2_json) { File.read(Rails.root + 'spec/import_examples/valid_lightweight_activity_import_v2.json') }
  let (:invalid_activity_import_json) { File.read(Rails.root + 'spec/import_examples/invalid_lightweight_activity_import.json') }
  let (:valid_sequence_import_v1_json) { File.read(Rails.root + 'spec/import_examples/valid_sequence_import_v1.json') }
  let (:valid_sequence_import_v2_json) { File.read(Rails.root + 'spec/import_examples/valid_sequence_import_v2.json') }
  let (:invalid_sequence_import_json) { File.read(Rails.root + 'spec/import_examples/invalid_sequence_import.json') }
  let (:valid_glossary_import_json) { File.read(Rails.root + 'spec/import_examples/valid_glossary_import.json') }
  let (:invalid_glossary_import_json) { File.read(Rails.root + 'spec/import_examples/invalid_glossary_import.json') }
  let (:valid_rubric_import_json) { File.read(Rails.root + 'spec/import_examples/valid_rubric_import.json') }
  let (:invalid_rubric_import_json) { File.read(Rails.root + 'spec/import_examples/invalid_rubric_import.json') }

  describe '#import' do
    context "lightweight activity" do
      it "can import a lightweight activity from a valid lightweight activity v1 json" do
        result = Import.import(valid_activity_import_v1_json, user)
        expect(result[:success]).to eq(true)
        expect(result[:import_item]).to be_a(LightweightActivity)
        expect(result[:type]).to eq("LightweightActivity")
      end

      it "can import a lightweight activity from a valid lightweight activity v2 json" do
        result = Import.import(valid_activity_import_v2_json, user)
        expect(result[:success]).to eq(true)
        expect(result[:import_item]).to be_a(LightweightActivity)
        expect(result[:type]).to eq("LightweightActivity")

        # make sure the sections import in correct order
        expect(result[:import_item].pages[0].sections.length).to eq(1)
        expect(result[:import_item].pages[1].sections.length).to eq(2)
        expect(result[:import_item].pages[2].sections.length).to eq(1)
        expect(result[:import_item].pages[3].sections.length).to eq(3)
      end

      it "returns error if input is incorrect" do
        result = Import.import(invalid_activity_import_json, user)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to be_a(String)
      end
    end

    context "sequence" do
      it "can import a sequence from a valid lightweight activity v1 json" do
        result = Import.import(valid_sequence_import_v1_json, user)
        expect(result[:success]).to eq(true)
        expect(result[:import_item]).to be_a(Sequence)
        expect(result[:type]).to eq("Sequence")
      end

      it "can import a sequence from a valid lightweight activity v2 json" do
        result = Import.import(valid_sequence_import_v1_json, user)
        expect(result[:success]).to eq(true)
        expect(result[:import_item]).to be_a(Sequence)
        expect(result[:type]).to eq("Sequence")
      end

      it "returns error if input is incorrect" do
        result = Import.import(invalid_sequence_import_json, user)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to be_a(String)
      end
    end

    context "glossary" do
      it "can import a glossary from a valid glossary json" do
        result = Import.import(valid_glossary_import_json, user)
        expect(result[:success]).to eq(true)
        expect(result[:import_item]).to be_a(Glossary)
        expect(result[:type]).to eq("Glossary")
      end

      it "returns error if input is incorrect" do
        result = Import.import(invalid_glossary_import_json, user)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to be_a(String)
      end
    end

    context "rubric" do
      it "can import a rubric from a valid rubric json" do
        result = Import.import(valid_rubric_import_json, user)
        expect(result[:success]).to eq(true)
        expect(result[:import_item]).to be_a(Rubric)
        expect(result[:type]).to eq("Rubric")
      end

      it "returns error if input is incorrect" do
        result = Import.import(invalid_rubric_import_json, user)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to be_a(String)
      end
    end

    it "handles Hash object as an input" do
      hash = JSON.parse(valid_activity_import_v1_json, :symbolize_names => true)
      result = Import.import(hash, user)
      expect(result[:success]).to eq(true)
      expect(result[:import_item]).to be_a(LightweightActivity)
      expect(result[:type]).to eq("LightweightActivity")
    end

    it "creates an Import instance in DB" do
      expect(Import.count).to eq(0)
      result = Import.import(valid_activity_import_v1_json, user)
      expect(Import.count).to eq(1)
      expect(Import.first.import_item).to eq(result[:import_item])
    end
  end
end
