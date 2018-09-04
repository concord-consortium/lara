{div, label, input, span, button} = ReactFactories

modulejs.define 'components/question_tracker/choice', [], () ->

    createReactClass
      updateIsCorrect: (evt) ->
        @props.onChange
          choice: @props.choice.choice
          id: @props.choice.id
          prompt: @props.choice.prompt
          is_correct: evt.target.checked

      updateChoice: (evt) ->
        @props.onChange
          choice: evt.target.value
          id: @props.choice.id
          is_correct: @props.choice.is_correct

      deleteChoice: ->
        @props.onDelete(@props.choice.id)

      render: ->
        (div {className: 'choice'},
          (div {className: 'input-group'},
            (div {className: 'delete-choice', onClick: @deleteChoice }, 'delete')
            (label {}, "Choice #{@props.number + 1}:")
            (input {type:'text', className: 'choice', onBlur: @updateChoice, defaultValue: @props.choice.choice})
            (label {}, 'Correct? ')
            (input {
              type: 'checkbox'
              className: 'is_correct'
              onClick: @updateIsCorrect
              defaultChecked: @props.choice.is_correct
            })
          )
        )
