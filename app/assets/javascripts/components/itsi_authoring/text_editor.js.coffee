{div, form, textarea, a} = React.DOM

modulejs.define 'components/itsi_authoring/text_editor',
['components/itsi_authoring/section_editor_mixin'],
(SectionEditorMixin) ->

  React.createClass

    mixins:
      [SectionEditorMixin]

    # NB: These methods will be moved into SectionEditorMixin once the JSON is defined
    getInitialState: ->
      text = if @props.section.data.text?.length > 0 then @props.section.data.text else ''
      initialState =
        text: text
        originalText: text
        edit: text.length is 0
    textChanged: (e) ->
      # NB: This will be moved into SectionEditorMixin once the JSON is defined
      @setState text: e.target.value
    edit: (e) ->
      e?.preventDefault()
      @setState edit: true
    cancel: (e) ->
      e?.preventDefault()
      @setState
        text: @state.originalText
        edit: false
    saveForm: (e) ->
      e?.preventDefault()
      alert 'TODO: saveForm()'
      @setState
        originalText: @state.text
        edit: false

    render: ->
      (div {className: 'ia-section-editor-element'},
        if @state.edit
          (form {className: 'ia-section-text-editor', onSubmit: @saveForm},
            (div {className: 'ia-section-editor-buttons'},
              (div {className: 'ia-save-btn', onClick: @saveForm}, 'Save')
              (a {href: '#', onClick: @cancel}, 'Cancel')
            )
            (div {style: {fontWeight: 'bold'}}, 'TODO: convert textarea to rich text editor AND implement saveForm()')
            (textarea {ref: 'textarea', value: @state.text, onChange: @textChanged})
          )
        else
          (div {className: 'ia-section-text'},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.text}})
          )
      )
