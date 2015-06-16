{div, label, input, span, a, form} = React.DOM

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

    componentWillMount: ->
      @editorMap =
        openResponse: OpenResponseQuestionEditor
        sensor: SensorEditor
        drawingResponse: DrawingResponseEditor
        model: ModelEditor

    getInitialState: ->
      selected: not @props.section.is_hidden

    selected: ->
      selected = (React.findDOMNode @refs.checkbox).checked
      $.ajax
        # TODO: figure out url for enable/disable
        url: "#{@props.section.update_url}/#{if selected then 'enable' else 'disable'}"
        type: 'POST'
      @setState selected: selected

    render: ->
      (div {className: 'ia-section-editor'},
        (label {},
          (input {type: 'checkbox', ref: 'checkbox', checked: @state.selected, onChange: @selected})
          (span {className: 'ia-section-editor-title'}, @props.title)
        )
        (div {className: 'ia-section-editor-elements', style: {display: if @state.selected then 'block' else 'none'}},
          (TextEditor {data: @props.section})
          for interactive, i in @props.section.interactives
            # todo map the url to a type
            type = 'model'
            (@editorMap[type] {key: "interactive#{i}", data: interactive})

          for embeddable, i in @props.section.embeddables
            # todo map the url to a type
            type = 'openResponse'
            (@editorMap[type] {key: "embeddable#{i}", data: embeddable})
        )
      )

