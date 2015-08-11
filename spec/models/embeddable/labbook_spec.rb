require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::Labbook do
  let(:labbook) { Embeddable::Labbook.new }

  describe '#to_hash' do
    it 'is implemented' do
      expect(labbook).to respond_to(:to_hash)
    end
    it 'has interesting attributes' do
      expected = {
        action_type: labbook.action_type,
        name: labbook.name,
        prompt: labbook.prompt,
        custom_action_label: labbook.custom_action_label,
        is_hidden: labbook.is_hidden
      }
      expect(labbook.to_hash).to eq(expected)
    end
  end
  describe "export" do
    let(:json){ emb.export.as_json }
    let(:emb) { labbook}
    it 'preserves is_hidden' do
      emb.is_hidden = true
      expect(json['is_hidden']).to eq true
    end
  end
  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(labbook.duplicate).to be_a_new(Embeddable::Labbook)
    end
  end

  describe '#action_label' do
    context 'labbook action type is set to upload' do
      let(:labbook) { Embeddable::Labbook.new(action_type: Embeddable::Labbook::UPLOAD_ACTION) }
      it 'returns "Upload image"' do
        expect(labbook.action_label).to eql(I18n.t('UPLOAD_IMAGE'))
      end
    end
    context 'labbook action type is set to snapshot' do
      let(:labbook) { Embeddable::Labbook.new(action_type: Embeddable::Labbook::SNAPSHOT_ACTION) }
      it 'returns "Take snapshot"' do
        expect(labbook.action_label).to eql(I18n.t('TAKE_SNAPSHOT'))
      end
    end
    context 'labbook has a custom action label defined' do
      let(:label) { 'label abc' }
      let(:labbook) do
        Embeddable::Labbook.new(action_type: Embeddable::Labbook::UPLOAD_ACTION,
                                custom_action_label: label)
      end
      it 'returns custom label' do
        expect(labbook.action_label).to eql(label)
      end
    end
  end

  describe 'its interactive' do
    let(:labbook) { Embeddable::Labbook.new args }
    let(:interactive) { nil }
    let(:action_type) { Embeddable::Labbook::SNAPSHOT_ACTION }
    let(:args) {{ interactive: interactive, action_type: action_type }}

    describe 'when it is not associated with an interactive' do
      it 'should have no interactive' do
        expect(labbook.interactive).to eql(nil)
      end
      it 'should be marked as disconnected' do
        expect(labbook.has_interactive?).to eql(false)
      end

      describe "When it is an upload only labbook" do
        let(:action_type) { Embeddable::Labbook::UPLOAD_ACTION}
        it 'it should show up in the runtime' do
          expect(labbook.show_in_runtime?).to eql(true)
        end
      end

      describe "When it is a snapshot labbook" do
        it 'it should not show up in the runtime' do
          expect(labbook.show_in_runtime?).to eql(false)
        end
      end
    end

    describe 'when it has an interactive' do
      let(:interactive) { MwInteractive.new }
      it 'should have an interactive' do
        expect(labbook.interactive).to eql(interactive)
      end
      it 'should be marked as connected' do
        expect(labbook.has_interactive?).to eql(true)
      end

      it 'it should show up in the runtime' do
        expect(labbook.show_in_runtime?).to eql(true)
      end

      describe "when the interactive is hidden" do
        let(:interactive) { MwInteractive.new(is_hidden: true)}
        it 'should have an interactive' do
          expect(labbook.interactive).to eql(interactive)
          expect(interactive.is_hidden).to eql(true)
          expect(labbook.action_type).to eql(Embeddable::Labbook::SNAPSHOT_ACTION)
        end
        it "should not show up in the runtime" do
          expect(labbook.show_in_runtime?).to eql(false)
        end

        describe "when it is an upload only labbook" do
          let(:action_type) { Embeddable::Labbook::UPLOAD_ACTION}
          it 'it should not show up in the runtime' do
            expect(labbook.show_in_runtime?).to eql(false)
          end
        end
      end
    end
  end

  describe "interactive methods" do
    let(:hidden_mw_interactive) { FactoryGirl.create(:hidden_mw_interactive) }
    let(:mw_interactive)        { FactoryGirl.create(:mw_interactive) }
    let(:interactives) { [] }
    let(:page)         { FactoryGirl.create(:page_with_or, interactives: interactives) }
    let(:args)         { {} }
    let(:labbook)      do
      lb = Embeddable::Labbook.create(args)
      page.add_embeddable(lb)
      lb
    end
    describe "#possible_interactives" do
      describe "when there aren't any interactives" do
        it "should return an empty list" do
          expect(labbook.possible_interactives).to be_empty
        end
      end

      describe "when there is one invisible interactives" do
        let(:interactives) { [hidden_mw_interactive] }
        it "should return the hidden interactive" do
          expect(labbook.possible_interactives).to include hidden_mw_interactive
        end
      end

      describe "when there is one visibile and one invisible interactive" do
        let(:interactives) { [hidden_mw_interactive, mw_interactive] }
        it "should return both of them" do
            expect(labbook.possible_interactives).to include mw_interactive
            expect(labbook.possible_interactives).to include hidden_mw_interactive
        end
      end
    end

    describe "#interactives_for_select" do
      let(:interactive_a)         { FactoryGirl.create(:mw_interactive) }
      let(:interactive_b)         { FactoryGirl.create(:mw_interactive) }

      let(:expected_identifier_1) { Embeddable::Labbook::NO_INTERACTIVE_SELECT }
      let(:expected_identifier_2) { ["Mw interactive (1)", "#{interactive_a.id}-MwInteractive"]}
      let(:expected_identifier_3) { ["Mw interactive (2)", "#{interactive_b.id}-MwInteractive"]}
      let(:expected_identifier_4) { ["Mw interactive (hidden)(3)", "#{hidden_mw_interactive.id}-MwInteractive"]}

      let(:interactives) { [interactive_a, interactive_b, hidden_mw_interactive] }
      it "should have good options" do
        expect(labbook.interactives_for_select).to include expected_identifier_1
        expect(labbook.interactives_for_select).to include expected_identifier_2
        expect(labbook.interactives_for_select).to include expected_identifier_3
        expect(labbook.interactives_for_select).to include expected_identifier_3
      end
    end
  end
end
