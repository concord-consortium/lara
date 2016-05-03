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
        @resetState()

      resetState: ->
        prompt: @props.question.prompt
        default_text: @props.question.default_text

      cancel: ->
        @setState @resetState()

      updatePrompt: (v) ->
        @setState
          prompt:v

      updateDefaultText: (evt) ->
        @setState
          default_text:evt.target.value

      save: ->
        @props.update
          action:
            type: "modifyMaster"
            question:
              prompt: @state.prompt
              default_text: @state.default_text

      render: ->
        (div {className: 'open-response-question'},
          if @props.edit
            (EditorForm {onSave: @save},
              (div {className: "text-input"},
                (label {}, 'Question prompt')
                (RichTextEditor {name:'prompt', text: @props.question.prompt, onChange: @updatePrompt})
              )
              (div {className: "text-input"},
                (label {}, 'Default text in answer area')
                (input {type: 'text', name: 'default_text', defaultValue: @props.question.default_text, onChange: @updateDefaultText })
              )
            )
          else
            (div {className: 'ia-section-text'},
              (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @props.question.prompt}})
              (textarea { defaultValue: @props.question.default_text, disabled: 'disabled'})
            )
        )
