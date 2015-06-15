{div, label, input, span} = React.DOM

modulejs.define 'components/itsi_authoring/section_editor',
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

  React.createClass

    statics:
      OpenResponseQuestion: OpenResponseQuestionEditor
      Sensor: SensorEditor
      DrawingResponse: DrawingResponseEditor
      Model: ModelEditor

    getInitialState: ->
      selected: @props.section.selected

    selected: ->
      @setState selected: (React.findDOMNode @refs.checkbox).checked

    render: ->
      embeddableIndex = 0
      interactiveIndex = 0

      (div {className: 'ia-section-editor'},
        (label {},
          (input {type: 'checkbox', ref: 'checkbox', checked: @state.selected, onClick: @selected})
          (span {className: 'ia-section-editor-title'}, @props.title)
        )
        (div {className: 'ia-section-editor-elements', style: {display: if @state.selected then 'block' else 'none'}},
          (TextEditor {section: @props.section, updateUrl: @props.updateUrl})
          for element, i in @props.elements
            renderedElement = (element {section: @props.section, key: i, embeddableIndex: embeddableIndex, interactiveIndex: interactiveIndex, updateUrl: @props.updateUrl})
            if element is OpenResponseQuestionEditor
              embeddableIndex++
            else
              interactiveIndex++
            renderedElement
        )
      )
