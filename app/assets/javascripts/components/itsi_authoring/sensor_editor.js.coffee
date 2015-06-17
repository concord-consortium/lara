{div, iframe, label} = React.DOM

modulejs.define 'components/itsi_authoring/sensor_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/itsi_authoring/sensor_list'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  sensorList
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass

  React.createClass

    mixins:
      [SectionElementEditorMixin]

    # maps form names to @props.data keys
    dataMap:
      'mw_interactive[name]': 'name'
      'mw_interactive[url]': 'url'
      'mw_interactive[image_url]': 'image_url'

    componentWillMount: ->
      @sensorOptions = []
      @sensorByName = {}
      for sensor in sensorList
        @sensorsByName[sensor.name] = sensor
        @sensorOptions.push
          name: sensor.name
          value: sensor.name

    initialEditState: ->
      not @props.data.image_url?

    onSelectChange: (key, value) ->
      # update url and image_url when the select changes
      sensor = @sensorsByName[value]
      @valueChanged 'mw_interactive[url]', sensor.url
      @valueChanged 'mw_interactive[image_url]', sensor.image_url

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Sensor', toHide: 'mw_interactive[is_hidden]', onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Sensor')
            (@select {name: 'mw_interactive[name]', options: @sensorOptions, onChange: @onSelectChange})
          )
        else
          (div {className: 'ia-section-text'},
            if @props.data.name
              (div {},
                (div {}, @props.data.name)
                (iframe {src: @props.data.image_url, width: '90%', height: 400})
              )
            else
              'No sensor selected'
          )
      )
