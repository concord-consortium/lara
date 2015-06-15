{div, label, input, span, a, form} = React.DOM

modulejs.define 'components/itsi_authoring/section_editor_form',
[],
->

  React.createClass
    render: ->
      (form {className: 'ia-section-editor-form', onSubmit: @props.onSave},
        (div {className: 'ia-section-editor-buttons'},
          (div {className: 'ia-save-btn', onClick: @props.onSave}, 'Save')
          (a {href: '#', onClick: @props.onCancel}, 'Cancel')
        )
        @props.children
      )
