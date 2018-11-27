{div, label, input, span, a, form} = ReactFactories

modulejs.define 'components/itsi_authoring/section_editor_form',
[],
->

  createReactClass

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
          (a {href: '#', onClick: @cancel}, 'Cancel')
        )
        @props.children
      )
