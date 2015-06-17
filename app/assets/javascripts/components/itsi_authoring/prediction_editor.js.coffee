{div, iframe, label} = React.DOM

modulejs.define 'components/itsi_authoring/prediction_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/itsi_authoring/prediction_list'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  predictionList
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
      @predictionOptions = []
      @predictionsByName = {}
      for prediction in predictionList
        @predictionsByName[prediction.name] = prediction
        @predictionOptions.push
          name: prediction.name
          value: prediction.name

    initialEditState: ->
      not @props.data.image_url?

    onSelectChange: (key, value) ->
      # update url and image_url when the select changes
      prediction = @predictionsByName[value]
      @valueChanged 'mw_interactive[name]', prediction.name
      @valueChanged 'mw_interactive[url]', prediction.url
      @valueChanged 'mw_interactive[image_url]', prediction.image_url

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Sensor', toHide: 'mw_interactive[is_hidden]', onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Sensor')
            (@select {name: 'mw_interactive[name]', options: @predictionOptions, onChange: @onSelectChange})
          )
        else
          (div {className: 'ia-section-text'},
            if @state.values['mw_interactive[name]']
              (div {},
                (div {}, @state.values['mw_interactive[name]'])
                (iframe {src: @state.values['mw_interactive[image_url]'], width: '90%', height: 400})
              )
            else
              'No sensor selected'
          )
      )
