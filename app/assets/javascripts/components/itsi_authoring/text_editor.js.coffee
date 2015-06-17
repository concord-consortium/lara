{div, form, textarea, a} = React.DOM

modulejs.define 'components/itsi_authoring/text_editor',
[
  'components/itsi_authoring/section_element_editor_mixin'
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/rich_text_editor',
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  RichTextEditorClass,
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  RichTextEditor = React.createFactory RichTextEditorClass

  React.createClass

    mixins:
      [SectionElementEditorMixin]

    # maps form names to @props.data keys
    dataMap:
      'interactive_page[text]': 'text'

    initialEditState: ->
      textLength = @props.data.text?.length or 0
      textLength is 0

    render: ->
      (div {className: 'ia-section-editor-element'},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (@richText {name: 'interactive_page[text]'})
          )
        else
          (div {className: 'ia-section-text'},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.values['interactive_page[text]']}})
          )
      )
