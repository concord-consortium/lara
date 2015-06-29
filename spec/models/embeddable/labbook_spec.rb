require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::Labbook do
  let(:labbook) { Embeddable::Labbook.new }

  describe '#to_hash' do
    it 'is implemented' do
      expect(labbook).to respond_to(:to_hash)
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
    let(:args)    { {} }
    let(:labbook) { Embeddable::Labbook.new args }
    describe 'when it is not associated with an interactive' do
      it 'should have no interactive' do
        expect(labbook.interactive).to eql(nil)
      end
      it 'should be marked as disconnected' do
        expect(labbook.is_connected?).to eql(false)
      end

      it 'it should not show up in the runtime' do
        expect(labbook.show_in_runtime?).to eql(false)
      end
    end
    describe 'when it has an interactive' do
      let(:interactive) { MwInteractive.new  }
      let(:args) { {interactive: interactive}}
      it 'should have an interactive' do
        expect(labbook.interactive).to eql(interactive)
      end
      it 'should be marked as connected' do
        expect(labbook.is_connected?).to eql(true)
      end

      it 'it should show up in the runtime' do
        expect(labbook.show_in_runtime?).to eql(true)
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

      describe "when there are only invisible interactives" do
        let(:interactives) { [hidden_mw_interactive] }
        it "should still return an empty list" do
          expect(labbook.possible_interactives).to be_empty
        end
      end

      describe "when there are visibile interactives" do
        let(:interactives) { [hidden_mw_interactive, mw_interactive] }
        it "should return one visible interactive" do
            expect(labbook.possible_interactives).to include mw_interactive
            expect(labbook.possible_interactives).not_to include hidden_mw_interactive
        end
      end
    end

    describe "#interactives_for_select" do
      let(:interactive_a)         { FactoryGirl.create(:mw_interactive) }
      let(:interactive_b)         { FactoryGirl.create(:mw_interactive) }
      let(:expected_identifier_a) { ["Mw interactive (1)", "#{interactive_a.id}-MwInteractive"]}
      let(:expected_identifier_b) { ["Mw interactive (2)", "#{interactive_b.id}-MwInteractive"]}
      let(:interactives) { [interactive_a, interactive_b] }
      it "should have good options" do
        expect(labbook.interactives_for_select).to include expected_identifier_a
        expect(labbook.interactives_for_select).to include expected_identifier_b
      end
    end
  end
end
