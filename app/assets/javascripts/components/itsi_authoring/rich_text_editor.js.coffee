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
      options = $.extend({}, window.ITSIEditorTinyMCEConfig)
      options.setup = (editor) =>
          # both events are needed as the 'change' event is only sent when the input loses focus (which handles menu choices like formatting)
          editor.on 'keyup', (e) =>
            @onChange editor
          editor.on 'change', (e) =>
            @onChange editor
      @node.tinymce options

    render: ->
      (textarea {ref: 'textarea', name: @props.name, cols: 100, rows: 5, defaultValue: @props.text})
