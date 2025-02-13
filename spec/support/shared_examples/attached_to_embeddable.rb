shared_examples "attached to embeddable" do
  let(:hidden_open_response_embeddable) { FactoryBot.create(:hidden_open_response) }
  let(:open_response_embeddable)        { FactoryBot.create(:open_response) }
  let(:embeddables) { [] }
  let(:page)        { FactoryBot.create(:page, embeddables: embeddables) }
  let(:args)        { {} }
  let(:test_embeddable) do
    e = described_class.create(args)
    page.add_embeddable(e)
    e.reload
    e
  end

  describe "#possible_embeddables" do
    describe "when there aren't any embeddables" do
      it "should return an empty list" do
        expect(test_embeddable.possible_embeddables).to be_empty
      end
    end

    describe "when there is one invisible embeddables" do
      let(:embeddables) { [hidden_open_response_embeddable] }
      it "should return the hidden embeddable" do
        expect(test_embeddable.possible_embeddables).to include hidden_open_response_embeddable
      end
    end

    describe "when there is one visibile and one invisible embeddable" do
      let(:embeddables) { [hidden_open_response_embeddable, open_response_embeddable] }
      it "should return both of them" do
        expect(test_embeddable.possible_embeddables).to include open_response_embeddable
        expect(test_embeddable.possible_embeddables).to include hidden_open_response_embeddable
      end
    end
  end

  describe "#embeddable" do
    it "when regular reference is used, it should return correct embeddable item" do
      test_embeddable.embeddable_select_value = test_embeddable.make_embeddable_select_value(open_response_embeddable)
      expect(test_embeddable.save).to eql(true)
      expect(test_embeddable.attached_to_embeddable).to eql(true)
      expect(test_embeddable.embeddable).to eql(open_response_embeddable)
    end

    it "when 'next embeddable' special value is used, it should return next embeddable from the same page" do
      test_embeddable.embeddable_select_value = AttachedToEmbeddable::NEXT_EMBEDDABLE_VALUE
      expect(test_embeddable.save).to eql(true)
      expect(test_embeddable.attached_to_embeddable).to eql(true)
      expect(test_embeddable.embeddable).to eql(nil) # no other embeddables on this page yet

      page.add_embeddable(open_response_embeddable)
      expect(test_embeddable.embeddable).to eql(open_response_embeddable)
    end
  end

  describe "#embeddables_for_select" do
    let(:embeddable_a)         { FactoryBot.create(:open_response) }
    let(:embeddable_b)         { FactoryBot.create(:open_response) }

    let(:expected_identifier_1) { AttachedToEmbeddable::NO_EMBEDDABLE_SELECT }
    let(:expected_identifier_2) { AttachedToEmbeddable::NEXT_EMBEDDABLE_SELECT }
    let(:expected_identifier_3) { ["Open response (1)", "#{embeddable_a.id}-Embeddable::OpenResponse"]}
    let(:expected_identifier_4) { ["Open response (2)", "#{embeddable_b.id}-Embeddable::OpenResponse"]}
    let(:expected_identifier_5) { ["Open response (hidden)(3)", "#{hidden_open_response_embeddable.id}-Embeddable::OpenResponse"]}

    let(:embeddables) { [embeddable_a, embeddable_b, hidden_open_response_embeddable] }
    it "should have good options" do
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_1
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_2
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_3
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_4
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_5
    end
  end
end
