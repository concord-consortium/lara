{div, label, input, textarea} = React.DOM

modulejs.define 'components/question_tracker/open_response',
  [
    'components/question_tracker/throttle_mixin',
    'components/common/rich_text_editor'
  ],
  (
    ThrottleMixin,
    RichTextEditorClass
  ) ->

    RichTextEditor = React.createFactory RichTextEditorClass

    React.createClass
      mixins:
        [ThrottleMixin]

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
        , => @throttle(200, @save)

      updateDefaultText: (evt) ->
        @setState
          default_text:evt.target.value
        , => @throttle(200, @save)

      save: ->
        @props.update
          action:
            type: "modifyMaster"
            question:
              prompt: @state.prompt
              default_text: @state.default_text

      render: ->
        (div {className: 'open-response-question'},
          (div {className: "text-input"},
            (label {}, 'Question prompt')
            (RichTextEditor {name:'prompt', text: @props.question.prompt, onChange: @updatePrompt})
          )
          (div {className: "text-input"},
            (label {}, 'Default text in answer area')
            (input {type: 'text', name: 'default_text', defaultValue: @props.question.default_text, onChange: @updateDefaultText })
          )
        )