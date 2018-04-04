{div, label, input, textarea, a, span} = React.DOM

modulejs.define 'components/itsi_authoring/open_response_question_editor',
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

  React.createClass

    mixins:
      [AjaxFormMixin]

    # maps form names to @props.data keys
    dataMap:
      'embeddable_open_response[prompt]': 'prompt'
      'embeddable_open_response[default_text]': 'default_text'

    initialEditState: ->
      (@props.data.prompt?.length or 0) is 0

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Open Response Question', toHide: 'embeddable_open_response[is_hidden]', onEdit: @edit, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Question prompt')
            (@richText {name: 'embeddable_open_response[prompt]', TinyMCEConfig: ITSITinyMCEConfig})

            (label {}, 'Default text in answer area')
            (@text {name: 'embeddable_open_response[default_text]'})
          )
        else
          (div {className: 'ia-section-text'},
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.values['embeddable_open_response[prompt]']}})
            (textarea {value: @state.values['embeddable_open_response[default_text]'], disabled: 'disabled'})
          )
      )
