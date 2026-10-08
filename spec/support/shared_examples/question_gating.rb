# Used by mw_interactive_spec.rb and managed_interactive_spec.rb

shared_examples "a question gating interactive" do |model_factory|
  let(:gating_fields) { {
    question_gating: "disable_following_in_section",
    question_gating_locked_text: "Run the model first",
    question_gating_unlocked_text: "Now answer the questions"
  } }
  let(:gated_interactive) { FactoryBot.create(model_factory, gating_fields) }

  def symbolized_export(item)
    JSON.parse(item.export.to_json, symbolize_names: true)
  end

  def import_and_save(import_hash)
    item = described_class.import(import_hash)
    item.save!(validate: false)
    item.reload
  end

  describe "question gating" do
    it "defaults to none with no banner texts" do
      item = FactoryBot.create(model_factory).reload
      expect(item.question_gating).to eq "none"
      expect(item.question_gating_locked_text).to be_nil
      expect(item.question_gating_unlocked_text).to be_nil
    end

    it "accepts each known value" do
      QuestionGating::VALUES.each do |value|
        expect(FactoryBot.build(model_factory, question_gating: value)).to be_valid
      end
    end

    it "rejects an unknown value" do
      item = FactoryBot.build(model_factory, question_gating: "sometimes")
      expect(item.save).to be false
      expect(item.errors[:question_gating]).not_to be_empty
    end

    it "saves blank and whitespace banner texts as nil and keeps real text" do
      item = FactoryBot.create(model_factory, question_gating_locked_text: "", question_gating_unlocked_text: "  \n")
      expect(item.reload.question_gating_locked_text).to be_nil
      expect(item.question_gating_unlocked_text).to be_nil

      item.update!(question_gating_locked_text: "Locked!")
      expect(item.reload.question_gating_locked_text).to eq "Locked!"
    end

    it "copies the fields in #duplicate" do
      expect(gated_interactive.duplicate).to be_a_new(described_class).with(gating_fields)
    end

    it "includes the fields in #export" do
      expect(symbolized_export(gated_interactive)).to include(gating_fields)
    end

    it "stores none when importing a null question_gating" do
      import_hash = symbolized_export(gated_interactive).merge(question_gating: nil)
      expect(import_and_save(import_hash).question_gating).to eq "none"
    end

    it "stores none when importing an unknown question_gating" do
      import_hash = symbolized_export(gated_interactive).merge(question_gating: "disable_following_in_activity")
      expect(import_and_save(import_hash).question_gating).to eq "none"
    end

    it "keeps the fields through a LaraSerializationHelper export and import" do
      exported = JSON.parse(LaraSerializationHelper.new.export(gated_interactive).to_json, symbolize_names: true)
      imported = LaraSerializationHelper.new.import(exported).reload
      expect(imported.question_gating_hash).to eq gating_fields
    end
  end
end
