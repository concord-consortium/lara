{div, label, input, textarea, button, span} = React.DOM

modulejs.define 'components/question_tracker/multiple_choice',
  [
    'components/itsi_authoring/section_editor_form',
    'components/itsi_authoring/rich_text_editor',
    'components/question_tracker/choice'
  ],
  (
    EditorFormClass,
    RichTextEditorClass
    ChoiceClass
  ) ->

    EditorForm     = React.createFactory EditorFormClass
    RichTextEditor = React.createFactory RichTextEditorClass
    Choice         = React.createFactory ChoiceClass

    React.createClass
      getInitialState: ->
        @resetState()

      resetState: ->
        prompt: @props.question.prompt
        choices: @props.question.choices

      cancel: ->
        @setState @resetState()

      updatePrompt: (v) ->
        @setState
          prompt:v

      updateChoice: (changed_choice) ->
        @props.update
          action:
            type: "updateChoice"
            choice: changed_choice

      save: ->
        @props.update
          action:
            type: "modifyMaster"
            question:
              prompt: @state.prompt
              "choices_attributes": @state.choices

      deleteChoice: (choice_id) ->
        @props.update
          action:
            type: "deleteChoice"
            choice_id: choice_id

      addChoice: ->
        @props.update
          action:
            type: "addChoice"

      render: ->
        (div {className: 'multiple-choice-question'},

          (EditorForm {onSave: @save},
            (div {className: 'input-group'},
              (label {key: 'prompt-label'}, 'Question prompt')
              (RichTextEditor {key: 'rich-text-editor', name:'prompt', text: @props.question.prompt, onChange: @updatePrompt})
            )
          )
          (button {key: 'button', className:'add-choice button', onClick: @addChoice}, "add new choice")
          for choice, i  in @props.question.choices
            (Choice {key: choice.id, number: i, choice: choice, onChange: @updateChoice, onDelete: @deleteChoice} )
        )
