{div} = React.DOM

modulejs.define 'components/question-tracker/alert', [], () ->
    React.createClass
      render: ->
        if @props.alert
          (div {className: "alert #{@props.alert.type}"}, @props.alert.text)
        else
          (div {className: "alert hidden"} )