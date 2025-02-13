# These shared examples are used by two model specs:
# mw_interactive.rb and managed_interactive.rb

shared_examples "a base interactive" do |model_factory|
  let (:interactive) { FactoryBot.create(model_factory) }

  describe "#portal_hash" do
    it 'returns properties supported by Portal' do
      expect(interactive.portal_hash).to include(
        type: 'iframe_interactive',
        is_required: false,
        name: interactive.name,
        url: interactive.url,
        native_width: interactive.native_width,
        native_height: interactive.native_height,
        display_in_iframe: interactive.reportable_in_iframe?
      )
      if interactive.instance_of?(MwInteractive)
        # To be backward compatible with MwInteractives already exported to Portal.
        expect(interactive.portal_hash[:id]).to eql(interactive.id)
      else
        # e.g. ManagedInteractive
        expect(interactive.portal_hash[:id]).to eql(interactive.embeddable_id)
      end
    end

    describe "when interactive pretends to be open response question" do
      let (:authored_state) { JSON({questionType: "open_response", prompt: "Test prompt", required: true}) }
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Portal' do
        expect(interactive.portal_hash).to include(
          type: 'open_response',
          prompt: "Test prompt",
          is_required: true,
          id: interactive.embeddable_id,
          name: interactive.name,
          url: interactive.url,
          native_width: interactive.native_width,
          native_height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end
    end

    describe "when interactive pretends to be image question" do
      let (:authored_state) { JSON({questionType: "image_question", prompt: "Test prompt", answerPrompt: "answer prompt", required: true}) }
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Portal' do
        expect(interactive.portal_hash).to include(
          type: "image_question",
          prompt: "Test prompt",
          drawing_prompt: "answer prompt",
          is_required: true,
          id: interactive.embeddable_id,
          name: interactive.name,
          url: interactive.url,
          native_width: interactive.native_width,
          native_height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end
    end

    describe "when interactive pretends to be multiple choice question" do
      let (:authored_state) do JSON({
        questionType: "multiple_choice", prompt: "Test prompt", required: true,
        choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}]
      }) end
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Portal' do
        expect(interactive.portal_hash).to include(
          type: 'multiple_choice',
          prompt: "Test prompt",
          is_required: true,
          choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}],
          id: interactive.embeddable_id,
          name: interactive.name,
          url: interactive.url,
          native_width: interactive.native_width,
          native_height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end
    end
  end

  describe "#portal_hash" do
    let (:authored_state) { JSON({questionType: "image_question", prompt: "<p>Lorem <strong>ipsum dolor sit amet</strong>, consectetur<br /> adipiscing elit. Duis porttitor tincidunt ante. Pellentesque suscipit sollicitudin condimentum. Vivamus gravida aliquam fringilla. Nunc pretium, urna eget accumsan interdum, turpis ante iaculis nisl, a condimentum nisl odio a ipsum. Aliquam erat volutpat. Nulla facilisi. Pellentesque ultrices rutrum est. Cras nec felis in orci porttitor iaculis in vel lectus. Nam aliquam mi sem, quis viverra ligula consequat at. Aliquam dictum eros felis, sit amet fermentum odio sagittis nec. Sed pretium dignissim commodo.</p>", answerPrompt: "answer prompt", required: true}) }
    let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state, name: nil) }

    it 'handles complex prompts' do
      expect(interactive.portal_hash).to include(
        name: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis porttitor tincidunt ante. Pellentesque suscipit sollicitudin condimentum. Vivamus gravida aliquam fringilla. Nunc pretium, urna eget ac..."
      )
    end
  end

  describe "#report_service_hash" do
    it 'returns properties supported by Report Service' do
      expect(interactive.report_service_hash).to include(
        type: 'iframe_interactive',
        id: interactive.embeddable_id,
        name: interactive.name,
        url: interactive.url,
        width: interactive.native_width,
        height: interactive.native_height,
        display_in_iframe: interactive.reportable_in_iframe?,
        question_number: interactive.index_in_activity,
        report_item_url: interactive.report_item_url

      )
    end

    describe "when interactive pretends to be open response question" do
      let (:authored_state) { JSON({questionType: "open_response", prompt: "Test prompt", required: true}) }
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Report Service' do
        expect(interactive.report_service_hash).to include(
          # Open response props:
          type: 'open_response',
          id: interactive.embeddable_id,
          prompt: "Test prompt",
          required: true,
          question_number: interactive.index_in_activity,
          # Interactive props:
          name: interactive.name,
          url: interactive.url,
          width: interactive.native_width,
          height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end
    end

    describe "when interactive pretends to be image question" do
      let (:authored_state) { JSON({questionType: "image_question", prompt: "Test prompt", answerPrompt: "answer prompt", required: true}) }
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Report Service' do
        expect(interactive.report_service_hash).to include(
          # IQ props:
          type: 'image_question',
          id: interactive.embeddable_id,
          prompt: "Test prompt",
          drawing_prompt: "answer prompt",
          required: true,
          question_number: interactive.index_in_activity,
          # Interactive props:
          name: interactive.name,
          url: interactive.url,
          width: interactive.native_width,
          height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end
    end

    describe "when interactive pretends to be multiple choice question" do
      let (:authored_state) do JSON({
        questionType: "multiple_choice", prompt: "Test prompt", required: true,
        choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}]
      }) end
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Report Service' do
        expect(interactive.report_service_hash).to include(
          # MC props:
          type: 'multiple_choice',
          id: interactive.embeddable_id,
          prompt: "Test prompt",
          required: true,
          choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}],
          question_number: interactive.index_in_activity,
          # Interactive props:
          name: interactive.name,
          url: interactive.url,
          width: interactive.native_width,
          height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end
    end
  end
end
