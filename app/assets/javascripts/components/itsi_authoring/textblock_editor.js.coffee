{div, textarea, a} = ReactFactories

modulejs.define 'components/itsi_authoring/textblock_editor',
[
  'components/common/ajax_form_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/itsi_authoring/tiny_mce_config'
],
(
  AjaxFormMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  ITSITinyMCEConfig
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass

  createReactClass

    mixins:
      [AjaxFormMixin]

    # maps form names to @props.data keys
    dataMap:
      'embeddable_xhtml[content]': 'content'

    initialEditState: ->
      (@props.data.prompt?.length or 0) is 0

    render: ->
      (div {className: 'ia-section-editor-element'},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (@richText {name: 'embeddable_xhtml[content]', TinyMCEConfig: ITSITinyMCEConfig})
          )
        else
          (div {className: 'ia-section-text'},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.values['embeddable_xhtml[content]']}})
          )
      )
