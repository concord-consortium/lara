{textarea} = ReactFactories

modulejs.define 'components/common/rich_text_editor',
[],
->

  createReactClass
    textarea: React.createRef()

    shouldComponentUpdate: ->
      false

    onChange: (editor) ->
      if @props.onChange
        @props.onChange editor.getContent()

    componentDidMount: ->
      $node = $(@textarea.current)
      options = $.extend({}, @props.TinyMCEConfig || window.TinyMCEConfig)
      options.setup = (editor) =>
          # both events are needed as the 'change' event is only sent when the input loses focus (which handles menu choices like formatting)
          editor.on 'keyup', (e) =>
            @onChange editor
          editor.on 'change', (e) =>
            @onChange editor

      $node.tinymce(options)

    render: ->
      (textarea {ref: @textarea, name: @props.name, cols: 100, rows: 5, defaultValue: @props.text})
