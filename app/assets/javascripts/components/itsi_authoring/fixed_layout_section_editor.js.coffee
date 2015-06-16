{div, label, input, span, a, form} = React.DOM

modulejs.define 'components/itsi_authoring/fixed_layout_section_editor',
[
  'components/itsi_authoring/open_response_question_editor'
  'components/itsi_authoring/sensor_editor'
  'components/itsi_authoring/drawing_response_editor'
  'components/itsi_authoring/model_editor'
  'components/itsi_authoring/text_editor'
],
(
  OpenResponseQuestionEditorClass,
  SensorEditorClass,
  DrawingResponseEditorClass,
  ModelEditorClass,
  TextEditorClass,
) ->

  OpenResponseQuestionEditor = React.createFactory OpenResponseQuestionEditorClass
  SensorEditor = React.createFactory SensorEditorClass
  DrawingResponseEditor = React.createFactory DrawingResponseEditorClass
  ModelEditor = React.createFactory ModelEditorClass
  TextEditor = React.createFactory TextEditorClass

  EditorForm = React.createFactory React.createClass
    render: ->
      (form {className: 'ia-section-editor-form', onSubmit: @props.onSave},
        (div {className: 'ia-section-editor-buttons'},
          (div {className: 'ia-save-btn', onClick: @props.onSave}, 'Save')
          (a {href: '#', onClick: @props.onCancel}, 'Cancel')
        )
        @props.children
      )

  React.createClass

    statics:
      OpenResponseQuestion: OpenResponseQuestionEditor
      Sensor: SensorEditor
      DrawingResponse: DrawingResponseEditor
      Model: ModelEditor

    getInitialState: ->
      selected: @props.section.selected

    selected: ->
      selected = (React.findDOMNode @refs.checkbox).checked
      $.ajax
        # TODO: figure out url for enable/disable
        url: "#{@props.section.data.update_url}/#{if selected then 'enable' else 'disable'}"
        type: 'POST'
      @setState selected: selected

    render: ->
      embeddableIndex = 0
      interactiveIndex = 0

      (div {className: 'ia-section-editor'},
        (label {},
          (input {type: 'checkbox', ref: 'checkbox', checked: @state.selected, onChange: @selected})
          (span {className: 'ia-section-editor-title'}, @props.title)
        )
        (div {className: 'ia-section-editor-elements', style: {display: if @state.selected then 'block' else 'none'}},
          (TextEditor {data: @props.section.data})
          for element, i in @props.elements
            if element is OpenResponseQuestionEditor
              elementData = @props.section.embeddables?[embeddableIndex] or {}
              embeddableIndex++
            else
              elementData = @props.section.interactives?[interactiveIndex] or {}
              interactiveIndex++
            (element {key: i, data: elementData})
        )
      )

