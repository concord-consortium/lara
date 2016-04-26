{div, label, input, span, a, form} = React.DOM

modulejs.define 'components/itsi_authoring/section_editor_form',
[],
->

  React.createClass

    save: (e) ->
      e?.preventDefault()
      @props.onSave?()

    cancel: (e) ->
      e.preventDefault()
      @props.onCancel?()

    render: ->
      (form {className: 'ia-section-editor-form', onSubmit: @save},
        (div {className: 'ia-section-editor-buttons'},
          (div {className: 'ia-save-btn', onClick: @save}, 'Save')
          if @props.onCancel
            (a {href: '#', onClick: @cancel}, 'Cancel')
        )
        @props.children
      )
