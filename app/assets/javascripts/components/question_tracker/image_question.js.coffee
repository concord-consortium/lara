{div, label, input, textarea, img, option, select} = React.DOM

modulejs.define 'components/question_tracker/image_question',
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

      sourceOptions: ->
        [
          {value: 'Shutterbug', label: 'Snap Shot'},
          {value: 'Drawing', label: 'Drawing'}
        ]


      resetState: ->
        prompt: @props.question.prompt
        bg_url: @props.question.bg_url
        drawing_prompt: @props.question.drawing_prompt
        bg_source: @props.question.bg_source

      cancel: ->
        @setState @resetState()

      updatePrompt: (v) ->
        @setState
          prompt:v

      updateDrawingPrompt: (v) ->
        @setState
          drawing_prompt:v

      updateBgUrl: (evt) ->
        @setState
          bg_url:evt.target.value

      updateBgSource: (evt) ->
        @setState
          bg_source:evt.target.value

      save: ->
        @props.update
          action:
            type: "modifyMaster"
            question:
              prompt: @state.prompt
              drawing_prompt: @state.drawing_prompt
              bg_url: @state.bg_url
              bg_source: @state.bg_source

      render: ->
        (div {className: 'image-question'},
          if @props.edit
            (EditorForm {onSave: @save},
              (div {className: 'select-input'},
                (label {}, 'Source: ')
                (select {defaultValue: @props.question.bg_source, onChange:@updateBgSource},
                  for o in @sourceOptions()
                    (option {value: o.value, key:o.value}, o.label)
                )
              )
              (div {className: 'input-group'},
                (label {}, 'Background Image')
                (input {type: 'bg_url', defaultValue: @props.question.bg_url, onChange: @updateBgUrl })
                if @state.bg_url?.length > 0
                  (div {className: "image-wrap"},
                    (img {className: "background-image", src: @props.question.bg_url})
                  )
              )
              (div {className: 'text-input'},
                (label {}, 'Text prompt')
                (RichTextEditor {name:'prompt', text: @props.question.prompt, onChange: @updatePrompt})
              )
              (div {className: 'text-input'},
                (label {}, 'Image prompt')
                (RichTextEditor {name:'drawing_prompt', text: @props.question.drawing_prompt, onChange: @updateDrawingPrompt})
              )
            )
          else
            (div {className: 'ia-section-text'},
              (div {
                className: 'ia-section-text-value',
                dangerouslySetInnerHTML: {__html: @props.question.prompt}
              })
              if (@props.question.bg_url)
                (img {className: "background-image", src: @props.question.bg_url})
            )
        )
