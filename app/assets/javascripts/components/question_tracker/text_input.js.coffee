{div, input, label} = ReactFactories

modulejs.define 'components/question_tracker/text_input',
  [],
  () ->

    createReactClass
      update: (evt) ->
        change = {"#{@props.name}": evt.target.value}
        @props.onChange?(change)

      render: ->
        (div {className: 'text-input'},
          (label {}, @props.label)
          (input {type:'text', defaultValue: @props.value, onBlur: @update })
        )
