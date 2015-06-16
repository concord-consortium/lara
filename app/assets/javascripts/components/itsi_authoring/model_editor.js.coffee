{div} = React.DOM

modulejs.define 'components/itsi_authoring/model_editor',
['components/itsi_authoring/section_element_editor_mixin'],
(SectionElementEditorMixin) ->

  React.createClass

    mixins:
      [SectionElementEditorMixin]

    render: ->
      (div {className: 'ia-section-editor-element'}, 'TODO: ModelEditor')
