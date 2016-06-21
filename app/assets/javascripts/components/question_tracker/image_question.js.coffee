{div, label, input, textarea, img, option, select} = React.DOM

modulejs.define 'components/question_tracker/image_question',
  ['components/question_tracker/throttle_mixin', 'components/itsi_authoring/rich_text_editor'],
  ( ThrottleMixin, RichTextEditorClass) ->

    RichTextEditor = React.createFactory RichTextEditorClass

    React.createClass
      mixins:
        [ThrottleMixin]

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
        , => @throttle(200, @save)

      updateDrawingPrompt: (v) ->
        @setState
          drawing_prompt:v
          , => @throttle(200, @save)

      updateBgUrl: (evt) ->
        @setState
          bg_url:evt.target.value
        , @save

      updateBgSource: (evt) ->
        @setState
          bg_source:evt.target.value
        , @save

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
            (div {className: 'select-input'},
              (label {}, 'Source: ')
              (select {defaultValue: @props.question.bg_source, onChange:@updateBgSource},
                for o in @sourceOptions()
                  (option {value: o.value, key:o.value}, o.label)
              )
            )
            (div {className: 'input-group'},
              (label {}, 'Background Image')
              (input {type: 'text', name: 'bg_url', defaultValue: @props.question.bg_url, onBlur: @updateBgUrl })
              if @state.bg_url?.length > 0
                (div {className: "image-wrap"},
                  (img {className: "background-image", src: @props.question.bg_url})
                )
            )

            (div {className: 'text-input'},
              (label {}, 'Image prompt')
              (RichTextEditor {name:'drawing_prompt', text: @props.question.drawing_prompt, onChange: @updateDrawingPrompt})
            )

            (div {className: 'text-input'},
              (label {}, 'Text prompt')
              (RichTextEditor {name:'prompt', text: @props.question.prompt, onChange: @updatePrompt})
            )
        )