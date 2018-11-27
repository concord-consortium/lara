{div} = ReactFactories

modulejs.define 'components/itsi_authoring/alert',
->
  createReactClass

    render: ->
      if @props.alert
        (div {className: "ia-alert-#{@props.alert.layout} ia-alert-#{@props.alert.type}"}, @props.alert.text)
      else
        (div {}, null)
