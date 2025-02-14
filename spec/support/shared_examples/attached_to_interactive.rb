shared_examples "attached to interactive" do
  let(:hidden_mw_interactive) { FactoryBot.create(:hidden_mw_interactive) }
  let(:mw_interactive)        { FactoryBot.create(:mw_interactive) }
  let(:interactives) { [] }
  let(:page)         { FactoryBot.create(:page_with_or, interactives: interactives) }
  let(:args)         { {} }
  let(:test_embeddable) do
    e = described_class.create(args)
    page.add_embeddable(e)
    e
  end

  describe "#possible_interactives" do
    describe "when there aren't any interactives" do
      it "should return an empty list" do
        expect(test_embeddable.possible_interactives).to be_empty
      end
    end

    describe "when there is one invisible interactives" do
      let(:interactives) { [hidden_mw_interactive] }
      it "should return the hidden interactive" do
        expect(test_embeddable.possible_interactives).to include hidden_mw_interactive
      end
    end

    describe "when there is one visibile and one invisible interactive" do
      let(:interactives) { [hidden_mw_interactive, mw_interactive] }
      it "should return both of them" do
        expect(test_embeddable.possible_interactives).to include mw_interactive
        expect(test_embeddable.possible_interactives).to include hidden_mw_interactive
      end
    end
  end

  describe "#interactives_for_select" do
    let(:interactive_a)         { FactoryBot.create(:mw_interactive) }
    let(:interactive_b)         { FactoryBot.create(:mw_interactive) }

    let(:expected_identifier_1) { AttachedToInteractive::NO_INTERACTIVE_SELECT }
    let(:expected_identifier_2) { ["Iframe Interactive (1)", "#{interactive_a.id}-MwInteractive"]}
    let(:expected_identifier_3) { ["Iframe Interactive (2)", "#{interactive_b.id}-MwInteractive"]}
    let(:expected_identifier_4) { ["Iframe Interactive (hidden)(3)", "#{hidden_mw_interactive.id}-MwInteractive"]}

    let(:interactives) { [interactive_a, interactive_b, hidden_mw_interactive] }
    it "should have good options" do
      expect(test_embeddable.interactives_for_select).to include expected_identifier_1
      expect(test_embeddable.interactives_for_select).to include expected_identifier_2
      expect(test_embeddable.interactives_for_select).to include expected_identifier_3
      expect(test_embeddable.interactives_for_select).to include expected_identifier_3
    end
  end
end
