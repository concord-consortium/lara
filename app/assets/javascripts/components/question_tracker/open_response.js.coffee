{div, label, input, textarea, a, span} = React.DOM

modulejs.define 'components/question_tracker/open_response',
  [
    'components/itsi_authoring/section_editor_form',
    'components/itsi_authoring/rich_text_editor'
  ],
  (
    EditorFormClass,
    RichTextEditorClass
  ) ->

    EditorForm     = React.createFactory EditorFormClass
    RichTextEditor = React.createFactory RichTextEditorClass

    React.createClass
      getInitialState: ->
        @props.initialState

      cancel: ->
        @setState @props.initialState
        @props.cancel?()

      updatePrompt: (v) ->
        @setState
          pompt:v

      updateDefaultText: (v) ->
        @setState
          defaultText:v

      save: ->
        question = @props.question
        @update
          question:
            id: @props.question.id
            type: @props.question.type
            question:
              prompt: @state.prompt
              defaultText: @state.defaultText

      render: ->

        (div {className: 'open-response-question'},
          if @props.edit
            (EditorForm {onSave: @save, onCancel: @cancel},
              (label {}, 'Question prompt')
              (RichTextEditor {name:prompt, defaultValue:prompt})

              (label {}, 'Default text in answer area')
              (input {name: defaultText, defaultValue: defaultText})
            )
          else
            (div {className: 'ia-section-text'},
              (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.prompt}})
              (textarea { defaultValue: @state.defaultText, disabled: 'disabled'})
            )
        )
