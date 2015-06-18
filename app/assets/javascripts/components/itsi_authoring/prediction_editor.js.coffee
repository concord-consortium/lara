{div, img, label} = React.DOM

modulejs.define 'components/itsi_authoring/prediction_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/itsi_authoring/cached_ajax'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  cachedAjax
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass
  SENSOR_PREDICTION_LIST_URL = 'https://s3.amazonaws.com/sensorconnector-s3.concord.org/sensor_prediction_list.json'

  React.createClass

    mixins:
      [SectionElementEditorMixin]

    # maps form names to @props.data keys
    dataMap:
      'mw_interactive[name]': 'name'
      'mw_interactive[url]': 'url'
      'mw_interactive[image_url]': 'image_url'

    getInitialState: ->
      modelsByName: {}
      modelOptions: []

    initialEditState: ->
      not @props.data.image_url?

    onSelectChange: (key, value) ->
      # update url and image_url when the select changes
      model = @state.modelsByName[value]
      @valueChanged 'mw_interactive[name]', model.name
      @valueChanged 'mw_interactive[url]', @processInteractiveUrl model.url
      @valueChanged 'mw_interactive[image_url]', model.image_url

    processInteractiveUrl: (newUrl) ->
      # Don't touch wrapper URL, replace `interactive` param only.
      @state.values['mw_interactive[url]'].replace(/interactive=.*?(&|$)/, 'interactive=' + newUrl)

    fetchModelList: ->
      cachedAjax
        url: SENSOR_PREDICTION_LIST_URL
        success: (data) =>
          if @isMounted()
            modelOptions = []
            modelsByName = {}
            for model in data
              modelsByName[model.name] = model
              modelOptions.push
                name: model.name
                value: model.name
            @setState
              modelOptions: modelOptions
              modelsByName: modelsByName

    switchToEditMode: ->
      @fetchModelList() if @state.modelOptions.length == 0
      @edit()

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Sensor', toHide: 'mw_interactive[is_hidden]', onEdit: @switchToEditMode},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Sensor')
            (@select {name: 'mw_interactive[name]', options: @state.modelOptions, onChange: @onSelectChange})
          )
        else
          (div {className: 'ia-section-text'},
            if @state.values['mw_interactive[name]']
              (div {},
                (div {}, @state.values['mw_interactive[name]'])
                (img {src: @state.values['mw_interactive[image_url]']})
              )
            else
              'No sensor selected'
          )
      )
