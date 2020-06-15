# These shared examples are used by two model specs:
# mw_interactive.rb and managed_interactive.rb

shared_examples "a base interactive" do |model_factory|
  describe "#portal_hash" do
    let (:interactive) { FactoryGirl.create(model_factory) }

    it 'returns properties supported by Portal' do
      expect(interactive.portal_hash).to include(
        type: 'iframe_interactive',
        is_required: false,
        id: interactive.id,
        name: interactive.name,
        url: interactive.url,
        native_width: interactive.native_width,
        native_height: interactive.native_height,
        display_in_iframe: interactive.reportable_in_iframe?,
        show_in_featured_question_report: interactive.show_in_featured_question_report
      )
    end

    describe "when interactive pretends to be open response question" do
      let (:authored_state) { JSON({questionType: "open_response", prompt: "Test prompt", required: true}) }
      let (:interactive) { FactoryGirl.create(model_factory, authored_state: authored_state) }

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
          display_in_iframe: interactive.reportable_in_iframe?,
          show_in_featured_question_report: interactive.show_in_featured_question_report
        )
      end
    end

    describe "when interactive pretends to be multiple choice question" do
      let (:authored_state) do JSON({
        questionType: "multiple_choice", prompt: "Test prompt", required: true,
        choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}]
      }) end
      let (:interactive) { FactoryGirl.create(model_factory, authored_state: authored_state) }

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
          display_in_iframe: interactive.reportable_in_iframe?,
          show_in_featured_question_report: interactive.show_in_featured_question_report
        )
      end
    end
  end
end
