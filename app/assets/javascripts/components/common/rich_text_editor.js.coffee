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
        @props.onChange $(@textarea.current).prop("value")

    componentDidMount: ->
      $node = $(@textarea.current)
      initSlateEditor($node, @props.text, 0, {useAjax: true})

    render: ->
      (textarea {ref: @textarea, name: @props.name, cols: 100, rows: 5, defaultValue: @props.text, onChange: this.onChange})
