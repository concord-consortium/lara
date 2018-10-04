{div, input, label, br, select, option} = ReactFactories

modulejs.define 'components/common/aspect_ratio_chooser', [], () ->

  SpecialNumericField = createReactClass

    getDefaultProps: ->
      disabled: true
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
        disabled: @props.disabled,
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

  numerberInput = React.createFactory SpecialNumericField

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

      updateValues: (newValues) ->
        console.log(newValues)

    myUpdate: (changes) ->
      @setState(changes)
      delayedUpdate = () =>
        @props.updateValues(@state)

      setTimeout(delayedUpdate,1)

    render: ->
      { mode, width, height } = @state
      { availableAspectRatios } = @props
      disabledInputs = if mode == 'MANUAL' then false else true
      inputStyle =
        'display': 'flex'
        'flex-direction': 'row'
        'flex-wrap': 'wrap'
        'margin-right': '0.5em'
        'opacity': if disabledInputs then '0.5' else '1.0'
      (div {style: {'padding': '1em', 'background-color': 'hsl(0,0%,95%'}},
        (select {
            style:{'margin': '.2em'}
            onChange: (e) => @myUpdate(mode: e.target.value)
          },
          availableAspectRatios.map (m) ->
            (option {value:m.key, label:m.value, selected: m.key==mode} )

        )
        (div {style: inputStyle},
          (numerberInput {
            disabled: disabledInputs
            value: width,
            label: 'width'
            onChange: (e) => @myUpdate({width: e.target.value})
          })
          (numerberInput {
            disabled: disabledInputs
            value: height,
            label: 'height',
            onChange: (e) => @myUpdate({height: e.target.value})
          })
        )
      )

