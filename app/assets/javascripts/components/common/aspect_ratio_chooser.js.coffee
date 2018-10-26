{div, input, label, br, select, option} = ReactFactories

modulejs.define 'components/common/aspect_ratio_chooser', [], () ->

  FormattedField = createReactClass
    getDefaultProps: ->
      inputWidth: '3em'
      value: 10
      label: 'input'

    label: ->
      (label {style:{
          'text-align': 'right'
          'padding': '0.2em'
        }},
        @props.label
      )

    value: ->
      (input {
        value: @props.value,
        onChange: @props.onChange,
        style: {
          width: @props.inputWidth
        }
      })

    render: ->
      (div {style: {
        'display': 'flex'
        'flex-direction': 'row'
        }} ,
        @label()
        @value()
      )

  numberInput = React.createFactory FormattedField

  AspectRatioChooser = createReactClass

    getInitialState: ->
      width:  @props.initialState.width
      height: @props.initialState.height
      mode: @props.initialState.mode

    getDefaultProps: ->
      initialState:
        width: 10,
        height: 10,
        mode: 'DEFAULT'

      availableAspectRatios: [
        {key: 'DEFAULT', value: "Default aspect ratio, or set by interactive …"},
        {key: 'MANUAL', value: "Manually set the native width & height …"},
        {key: 'MAX', value: "Use all available space for the interactive …"}
      ]

      updateValues: (newValues) -> console.log(newValues)

    # Update the internal state, then call this.props.updateValues(state)
    myUpdate: (changes) ->
      @setState(changes)
      delayedUpdate = () =>
        @props.updateValues(@state)
      # Wait for the end of the event loop:
      setTimeout(delayedUpdate, 1)

    render: ->
      { mode, width, height } = @state
      { availableAspectRatios } = @props
      enabledInputs = if mode == 'MANUAL' then true else false
      inputStyle =
        'display': 'flex'
        'flex-direction': 'row'
        'flex-wrap': 'wrap'
        'margin-right': '0.5em'
      (div {style: {'display': 'flex', 'flex-direction': 'row', 'padding': '0.5em'}},
        (select {
            style:{'margin': '.2em'}
            onChange: (e) => @myUpdate(mode: e.target.value)
          },
          availableAspectRatios.map (m) ->
            (option {value:m.key, label:m.value, selected: m.key==mode}, m.value)
        )
        if enabledInputs
          (div {style: inputStyle},
            (numberInput {
              value: width,
              label: 'width'
              onChange: (e) => @myUpdate({width: e.target.value})
            })
            (numberInput {
              value: height,
              label: 'height',
              onChange: (e) => @myUpdate({height: e.target.value})
            })
          )
        else ""
      )

