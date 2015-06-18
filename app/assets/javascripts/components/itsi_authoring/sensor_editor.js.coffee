{div, img, label} = React.DOM

modulejs.define 'components/itsi_authoring/sensor_editor',
[
  'components/itsi_authoring/section_editor_element'
],
(
  SectionEditorElementClass
) ->

  SectionEditorElement = React.createFactory SectionEditorElementClass

  React.createClass

    render: ->
      (SectionEditorElement {data: @props.data, title: 'Sensor', toHide: 'mw_interactive[is_hidden]', alert: @props.alert},
        (div {className: 'ia-section-text'},
          (div {},
            (div {}, 'Data Collector')
            (img {src: @props.data.image_url})
          )
        )
      )
