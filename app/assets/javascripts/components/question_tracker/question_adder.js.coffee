{div, label, select, option} = React.DOM

modulejs.define 'components/question_tracker/question_adder',
  [],
  () ->

    React.createClass

      options: ->
        [
          {type: "Embeddable::OpenResponse", name: "Open Response"}
          {type: "Embeddable::MultipleChoice", name: "Multiple Choice"}
          {type: "Embeddable::ImageQuestion", name: "Image Question"}
        ]

      onChange: (select_evt) ->
        selectValue = select_evt.target.value
        newValue =
          action:
            type: "replaceMaster"
            value: selectValue
            lastValue: @props.question
        @props.update newValue

      render: ->
        question = @props.question
        update = @update
        can_update = @props.edit
        (div {className: 'add-question'},
          (label {}, "Question Type:")
          (select {defaultValue: question.type, onChange:@onChange, disabled: not can_update },
            for o in @options()
              (option {value: o.type, key:o.type}, o.name)
          )
        )