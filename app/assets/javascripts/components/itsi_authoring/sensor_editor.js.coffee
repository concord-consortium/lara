{div, img, label} = React.DOM

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

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Sensor', toHide: 'mw_interactive[is_hidden]', onEdit: @edit, alert: @props.alert, confirmHide: @props.confirmHide},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, "The sensor can't be customized. It will automatically detect the type of the connected sensor.")
            (div {style: {marginTop: 10}},
              (div {}, 'Data Collector')
              (img {src: @props.data.image_url})
            )
          )
        else
          (div {className: 'ia-section-text'},
            (div {},
              (div {}, 'Data Collector')
              (img {src: @props.data.image_url})
            )
          )
      )
