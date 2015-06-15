{textarea} = React.DOM

modulejs.define 'components/itsi_authoring/rich_text_editor',
[],
->

  React.createClass
    render: ->
      (textarea {ref: 'textarea', value: @props.text, onChange: @props.onChange})
