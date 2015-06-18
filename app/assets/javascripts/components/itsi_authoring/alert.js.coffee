{div} = React.DOM

modulejs.define 'components/itsi_authoring/alert',
->
  React.createClass

    render: ->
      if @props.alert
        (div {className: "ia-alert-#{@props.alert.layout} ia-alert-#{@props.alert.type}"}, @props.alert.text)
      else
        (div {}, null)
