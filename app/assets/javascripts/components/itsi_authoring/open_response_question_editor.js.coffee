{div, label, input, textarea, a, span} = React.DOM

modulejs.define 'components/itsi_authoring/open_response_question_editor',
[
  'components/itsi_authoring/section_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/rich_text_editor'
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

    edit: (e) ->
      e?.preventDefault()
      @setState edit: true

    cancel: (e) ->
      e?.preventDefault()
      @setState
        prompt: @state.originalPrompt
        defaultText: @state.originalDefaultText
        edit: false

    saveForm: (e) ->
      e?.preventDefault()
      alert 'TODO: saveForm()'
      @setState
        originalPrompt: @state.prompt
        originalDefaultText: @state.defaultText
        edit: false

    selected: ->
      @setState selected: (React.findDOMNode @refs.checkbox).checked

    render: ->
      (div {className: 'ia-section-editor-element'},
        (label {},
          (input {type: 'checkbox', ref: 'checkbox', checked: @state.selected, onChange: @selected})
          (span {className: 'ia-section-editor-title'}, 'Open Response Question')
        )
        (div {className: 'ia-section-editor-elements', style: {display: if @state.selected then 'block' else 'none'}},
          if @state.edit
            (SectionEditorForm {onSave: @saveForm, onCancel: @cancel},
              (label {}, 'Question prompt')
              (RichTextEditor {text: @state.prompt, onChange: @richTextChanged})
              (label {}, 'Default text in answer area')
              (input {type: 'text', value: @state.defaultText, onChange: @inputChanged})
            )
          else
            (div {className: 'ia-section-text'},
              (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
              (div {className: 'ia-section-text-value', dangerouslySetInnerHTML: {__html: @state.prompt}})
              (textarea {value: @state.defaultText, disabled: 'disabled'})
            )
        )
      )
