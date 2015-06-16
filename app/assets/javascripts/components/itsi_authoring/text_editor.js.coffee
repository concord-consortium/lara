{div, form, textarea, a} = React.DOM

modulejs.define 'components/itsi_authoring/text_editor',
[
  'components/itsi_authoring/section_editor_mixin'
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/rich_text_editor',
],
(
  SectionEditorMixin,
  SectionEditorFormClass,
  RichTextEditorClass,
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  RichTextEditor = React.createFactory RichTextEditorClass

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
    richTextChanged: (newText) ->
      @setState text: newText
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
          (SectionEditorForm {onSave: @saveForm, onCancel: @cancel},
            (div {style: {fontWeight: 'bold'}}, 'TODO: implement saveForm()')
            (RichTextEditor {text: @state.text, onChange: @richTextChanged})
          )
        else
          (div {className: 'ia-section-text'},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.text}})
          )
      )
