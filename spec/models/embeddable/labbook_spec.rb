require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::Labbook do
  it_behaves_like "a question"
  it_behaves_like "attached to interactive"

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
        is_hidden: labbook.is_hidden,
        show_in_featured_question_report: labbook.show_in_featured_question_report,
        is_half_width: labbook.is_half_width,
        hint: labbook.hint
      }
      expect(labbook.to_hash).to eq(expected)
    end
  end

  describe "#export" do
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

  describe "#portal_hash" do
    it 'returns properties supported by Portal' do
      expect(labbook.portal_hash).to eq(
        type: 'iframe_interactive',
        id: labbook.portal_id,
        name: labbook.name,
        show_in_featured_question_report: labbook.show_in_featured_question_report,
        display_in_iframe: true,
        native_width: 600,
        native_height: 500
      )
    end
  end

  describe '#action_label' do
    context 'labbook action type is set to upload' do
      let(:labbook) { Embeddable::Labbook.new(action_type: Embeddable::Labbook::UPLOAD_ACTION) }
      it 'returns "Upload image"' do
        expect(labbook.action_label).to eql(I18n.t('UPLOAD_IMAGE'))
      end
      context 'if we manually override custom_action_label' do
        it 'returns "Take snapshot"' do
          labbook.custom_action_label = I18n.t('TAKE_SNAPSHOT')
          expect(labbook.action_label).to eql(I18n.t('TAKE_SNAPSHOT'))
        end
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

  describe "#update_itsi_prompts" do
    let(:labbook) { Embeddable::Labbook.create(prompt: prompt) }

    before(:each) do
      labbook
      Embeddable::Labbook.update_itsi_prompts
      labbook.reload
    end

    describe "when the prompt is nil" do
      let(:prompt) { nil }
      it "the prompt should not be changed" do
        expect(labbook.prompt).to eql prompt
      end
    end

    describe "when the prompt is empty" do
      let(:prompt) { "" }
      it "the prompt should not be changed" do
        expect(labbook.prompt).to eql prompt
      end
    end

    describe "when the promt is something random" do
      let(:prompt) { "describe why these two things look so similar "}
      it "the prompt should not be changed" do
        expect(labbook.prompt).to eql prompt
      end
    end

    describe "when the promt is the old snapshot prompt" do
      let(:prompt) { I18n.t("LABBOOK.OLD_ITSI.SNAPSHOT_PROMPT") }
      it "the prompt should be updated to the new snapshot prompt" do
        expect(labbook.prompt).to eql I18n.t("LABBOOK.ITSI.SNAPSHOT_PROMPT")
      end
    end
    describe "when the promt is the old itsi upload prompt" do
      let(:prompt) { I18n.t("LABBOOK.OLD_ITSI.UPLOAD_PROMPT") }
      it "the prompt should be updated to the new upload prompt" do
        expect(labbook.prompt).to eql I18n.t("LABBOOK.ITSI.UPLOAD_PROMPT")
      end
    end
  end
end
