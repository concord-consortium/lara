{div} = React.DOM

modulejs.define 'components/itsi_authoring/sensor_editor',
['components/itsi_authoring/section_editor_mixin'],
(SectionEditorMixin) ->

  React.createClass

    mixins:
      [SectionEditorMixin]

    render: ->
      (div {className: 'ia-section-editor-element'}, 'TODO: SensorEditor')
