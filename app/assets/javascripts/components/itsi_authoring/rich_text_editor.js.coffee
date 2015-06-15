{textarea} = React.DOM

modulejs.define 'components/itsi_authoring/rich_text_editor',
[],
->

  React.createClass
    shouldComponentUpdate: ->
      false

    onChange: (e) ->
      @props.onChange $.wysiwyg.getContent(@node)

    componentDidMount: ->
      @node = $(React.findDOMNode(@refs.textarea))
      @node.wysiwyg({controls: {html: {visible: true}}, events: {save: @onChange}})

    render: ->
      (textarea {ref: 'textarea', cols: 100, rows: 5, value: @props.text, onChange: @props.onChange})

