{div, label, button} = ReactFactories

modulejs.define 'components/question_tracker/multiple_choice',
  [
    'components/question_tracker/throttle_mixin',
    'components/common/rich_text_editor',
    'components/question_tracker/choice'
  ],
  (
    ThrottleMixin,
    RichTextEditorClass,
    ChoiceClass
  ) ->

    RichTextEditor = React.createFactory RichTextEditorClass
    Choice         = React.createFactory ChoiceClass

    createReactClass
      mixins:
        [ThrottleMixin]

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
        , => @throttle(200, @save)

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
          (div {className: 'input-group'},
            (label {key: 'prompt-label'}, 'Question prompt')
            (RichTextEditor {key: 'rich-text-editor', name:'prompt', text: @props.question.prompt, onChange: @updatePrompt})
          )
          (button {key: 'button', className:'add-choice button', onClick: @addChoice}, "add new choice")
          for choice, i  in @props.question.choices
            (Choice {key: choice.id, number: i, choice: choice, onChange: @updateChoice, onDelete: @deleteChoice} )
        )
