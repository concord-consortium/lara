{div, label, input, textarea, a, span} = React.DOM

modulejs.define 'components/itsi_authoring/open_response_question_editor',
[
  'components/itsi_authoring/section_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/rich_text_editor',
  'components/itsi_authoring/section_editor_element'
],
(
  SectionEditorMixin,
  SectionEditorFormClass,
  RichTextEditorClass,
  SectionEditorElementClass,
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  RichTextEditor = React.createFactory RichTextEditorClass
  SectionEditorElement = React.createFactory SectionEditorElementClass

  React.createClass

    mixins:
      [SectionEditorMixin]

    # NB: These methods will be moved into SectionEditorMixin once the JSON is defined
    getInitialState: ->
      prompt = if @props.section.data.prompt?.length > 0 then @props.section.data.prompt else ''
      defaultText = if @props.section.data.default_text?.length > 0 then @props.section.data.default_text else ''
      initialState =
        prompt: prompt
        originalPrompt: prompt
        defaultText: defaultText
        originalDefaultText: defaultText
        edit: false
        selected: false

    richTextChanged: (newText) ->
      @setState prompt: newText

    inputChanged: (e) ->
      @setState defaultText: e.target.value

    edit: ->
      @setState edit: true

    cancel: ->
      @setState
        prompt: @state.originalPrompt
        defaultText: @state.originalDefaultText
        edit: false

    saveForm: ->
      @setState
        originalPrompt: @state.prompt
        originalDefaultText: @state.defaultText
        edit: false

    render: ->
      (SectionEditorElement {title: 'Open Response Question', selected: false, onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @saveForm, onCancel: @cancel},
            (label {}, 'Question prompt')
            (RichTextEditor {text: @state.prompt, onChange: @richTextChanged})
            (label {}, 'Default text in answer area')
            (input {type: 'text', value: @state.defaultText, onChange: @inputChanged})
          )
        else
          (div {className: 'ia-section-text'},
            (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.prompt}})
            (textarea {value: @state.defaultText, disabled: 'disabled'})
          )
      )
