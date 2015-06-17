{div, img, label} = React.DOM

modulejs.define 'components/itsi_authoring/model_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element',
  'components/itsi_authoring/model_list'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass,
  modelList
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
      @modelOptions = []
      @modelsByName = {}
      for model in modelList
        @modelsByName[model.name] = model
        @modelOptions.push
          name: model.name
          value: model.name

    initialEditState: ->
      not @props.data.image_url?

    onSelectChange: (key, value) ->
      # update url and image_url when the select changes
      model = @modelsByName[value]
      @valueChanged 'mw_interactive[url]', model.url
      @valueChanged 'mw_interactive[image_url]', model.image_url

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Model', toHide: 'mw_interactive[is_hidden]', onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Model')
            (@select {name: 'mw_interactive[name]', options: @modelOptions, onChange: @onSelectChange})
          )
        else
          (div {className: 'ia-section-text'},
            if @state.values['mw_interactive[name]']
              (div {},
                (div {}, @state.values['mw_interactive[name]'])
                (img {src: @state.values['mw_interactive[image_url]']})
              )
            else
              'No model selected'
          )
      )
