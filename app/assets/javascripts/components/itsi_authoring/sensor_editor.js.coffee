{div, iframe} = React.DOM

modulejs.define 'components/itsi_authoring/sensor_editor',
[
  'components/itsi_authoring/section_element_editor_mixin',
  'components/itsi_authoring/section_editor_form',
  'components/itsi_authoring/section_editor_element'
],
(
  SectionElementEditorMixin,
  SectionEditorFormClass,
  SectionEditorElementClass
) ->

  SectionEditorForm = React.createFactory SectionEditorFormClass
  SectionEditorElement = React.createFactory SectionEditorElementClass

  React.createClass

    mixins:
      [SectionElementEditorMixin]

    # maps form names to @props.data keys
    dataMap: {} # TODO: mapping

    initialEditState: ->
      not @props.data.image_url?

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Sensor', selected: false, onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            'TODO: *** SENSOR EDITOR GOES HERE ***'
          )
        else
          (div {className: 'ia-section-text'},
            if @props.data.name
              (div {},
                (div {}, @props.data.name)
                (iframe {src: @props.data.url, width: '90%', height: 400})
              )
            else
              'No sensor selected'
          )
      )
