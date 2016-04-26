{div, input, label} = React.DOM

modulejs.define 'components/question_tracker/text_input',
  [],
  () ->

    React.createClass
      update: (evt) ->
        change = {"#{@props.name}": evt.target.value}
        console.log change
        @props.onChange?(change)

      render: ->
        (div {className: 'text-input'},
          (label {}, @props.label)
          (input {type:'text', defaultValue: @props.value, onBlur: @update })
        )