{div} = ReactFactories

modulejs.define 'components/question-tracker/alert', [], () ->
    createReactClass
      render: ->
        if @props.alert
          (div {className: "alert #{@props.alert.type}"}, @props.alert.text)
        else
          (div {className: "alert hidden"} )
