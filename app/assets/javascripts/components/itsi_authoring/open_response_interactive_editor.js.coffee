{div, label, input, textarea, a, span} = ReactFactories

modulejs.define 'components/itsi_authoring/open_response_interactive_editor',
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
      'managed_interactive_open_response[prompt]': 'prompt'
      'managed_interactive_open_response[default_text]': 'default_text'

    initialEditState: ->
      (@props.data.prompt?.length or 0) is 0

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Open Response Interactive', toHide: 'managed_interactive_open_response[is_hidden]', onEdit: @edit, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Question prompt')
            (@richText {name: 'managed_interactive_open_response[prompt]', TinyMCEConfig: ITSITinyMCEConfig})

            (label {}, 'Default text in answer area')
            (@text {name: 'managed_interactive_open_response[default_text]'})

          )
        else
          (div {className: 'ia-section-text'},
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.values['managed_interactive_open_response[prompt]']}})
            (textarea {value: @state.values['managed_interactive_open_response[default_text]'], disabled: 'disabled'})
          )
      )
