{textarea} = React.DOM

modulejs.define 'components/itsi_authoring/rich_text_editor',
[],
->

  React.createClass
    shouldComponentUpdate: ->
      false

    onChange: (editor) ->
      @props.onChange editor.getContent()

    componentDidMount: ->
      @node = $(React.findDOMNode(@refs.textarea))
      @node.tinymce
        menubar: false
        statusbar: false
        toolbar_items_size: 'small'
        toolbar: "undo redo | bold italic strikethrough underline | aligncenter alignjustify alignleft alignright indent outdent | subscript superscript | numlist bullist | link unlink | hr image table"
        plugins: 'paste link hr image table'
        paste_as_text: true
        setup: (editor) =>
          # both events are needed as the 'change' event is only sent when the input loses focus (which handles menu choices like formatting)
          editor.on 'keyup', (e) =>
            @onChange editor
          editor.on 'change', (e) =>
            @onChange editor

    render: ->
      (textarea {ref: 'textarea', name: @props.name, cols: 100, rows: 5, defaultValue: @props.text})

