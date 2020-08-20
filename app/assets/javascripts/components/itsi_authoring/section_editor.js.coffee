{div, label, input, span, a, form} = ReactFactories

modulejs.define 'components/itsi_authoring/section_editor',
[
  'components/itsi_authoring/open_response_question_editor'
  'components/itsi_authoring/sensor_editor'
  'components/itsi_authoring/prediction_editor'
  'components/itsi_authoring/drawing_response_editor'
  'components/itsi_authoring/model_editor'
  'components/itsi_authoring/managed_interactive_editor'
  'components/itsi_authoring/textblock_editor'
],
(
  OpenResponseQuestionEditorClass,
  SensorEditorClass,
  PredictionEditorClass,
  DrawingResponseEditorClass,
  ModelEditorClass,
  ManagedInteractiveEditorClass,
  TextBlockEditorClass,
) ->

  OpenResponseQuestionEditor = React.createFactory OpenResponseQuestionEditorClass
  SensorEditor = React.createFactory SensorEditorClass
  PredictionEditor = React.createFactory PredictionEditorClass
  DrawingResponseEditor = React.createFactory DrawingResponseEditorClass
  ModelEditor = React.createFactory ModelEditorClass
  ManagedInteractiveEditor = React.createFactory ManagedInteractiveEditorClass
  TextBlockEditor = React.createFactory TextBlockEditorClass

  createReactClass

    getInitialState: ->
      selected: not @props.section.is_hidden

    selected: (e) ->
      selected = e.target.checked
      if not selected and not @props.confirmHide()
        e.preventDefault()
        return
      $.ajax
        url: "#{@props.section.update_url}.json"
        type: 'POST'
        data:
          _method: 'PUT'
          interactive_page:
            is_hidden: if selected then 0 else 1
        success: =>
          @props.alert 'info', 'Saved'
        error: =>
          @props.alert 'error', 'Save Failed!'
      @setState selected: selected

    getEditorForInteractiveElement: (element) ->
      return ModelEditor unless element.url
      url = decodeURIComponent element.url
      if /globalStateKey/.test url
        if /sensor-connector\.json/.test url
          return SensorEditor
        else
          return PredictionEditor
      ModelEditor

    getEditorForEmbeddedElement: (element) ->
      switch element.type
        when 'image_question' then DrawingResponseEditor
        when 'open_response' then OpenResponseQuestionEditor
        when 'managed_interactive' then ManagedInteractiveEditor
        when 'xhtml' then TextBlockEditor
        else null

    render: ->
      (div {className: 'ia-section-editor'},
        (label {},
          (input {type: 'checkbox', checked: @state.selected, onChange: @selected})
          (span {className: 'ia-section-editor-title'}, @props.title)
        )
        (div {className: 'ia-section-editor-elements', style: {display: if @state.selected then 'block' else 'none'}},
          for embeddable, i in @props.section.header_embeddables
            editor = @getEditorForEmbeddedElement embeddable
            if editor
              (editor {key: "embeddable#{i}", data: embeddable, alert: @props.alert, confirmHide: @props.confirmHide})
          for interactive, i in @props.section.interactives
            editor = @getEditorForInteractiveElement interactive
            if editor
              (editor {key: "interactive#{i}", data: interactive, alert: @props.alert, confirmHide: @props.confirmHide, jsonListUrls: @props.jsonListUrls})
          for embeddable, i in @props.section.embeddables
            editor = @getEditorForEmbeddedElement embeddable
            if editor
              (editor {key: "embeddable#{i}", data: embeddable, alert: @props.alert, confirmHide: @props.confirmHide})
        )
      )
