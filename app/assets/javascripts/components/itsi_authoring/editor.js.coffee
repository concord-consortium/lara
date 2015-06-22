{div} = React.DOM

modulejs.define 'components/itsi_authoring/editor',
[
  'components/itsi_authoring/metadata_editor',
  'components/itsi_authoring/section_editor',
  'components/itsi_authoring/alert',
],
(
  MetadataEditorClass,
  SectionEditorClass,
  AlertClass
) ->

  MetadataEditor = React.createFactory MetadataEditorClass
  SectionEditor = React.createFactory SectionEditorClass
  Alert = React.createFactory AlertClass

  React.createClass

    componentWillMount: ->
      @alerts = []

    getInitialState: ->
      alert: null

    _processAlertQueue: ->
      if @alerts.length > 0
        @setState alert: @alerts.shift()
        setTimeout (=> @_processAlertQueue()), 1000
      else
        @setState alert: null

    alert: (type, text, layout='bar') ->  # other layout option is 'pill'
      @alerts.push
        type: type
        text: text
        layout: layout
      @_processAlertQueue() if @alerts.length is 1

    render: ->
      (div {className: 'ia-editor'},
        (Alert {alert: @state.alert}) if @state.alert
        (MetadataEditor {metadata: @props.metadata, alert: @alert})
        (div {className: 'ia-editor-sections'},
          for section, i in @props.sections
            # ignore the 'Test page'
            if section.name isnt 'Test page'
              title = if name is 'Second Career STEM Question' then 'Concluding Career STEM Question' else section.name
              (SectionEditor {section: section, title: title, key: i, alert: @alert})
        )
      )
