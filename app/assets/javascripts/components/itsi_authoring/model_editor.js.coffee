{div, img} = React.DOM

modulejs.define 'components/itsi_authoring/model_editor',
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
    dataMap:
      'embeddable_diy_emdedded_model[diy_model_id]': 'model' # TODO: get correct mapping

    initialEditState: ->
      not @props.data.image_url?

    render: ->
      modelOptions = [] # TODO: get options for model

      (SectionEditorElement {data: @props.data, title: 'Model', selected: false, onEdit: @edit},
        if @state.edit
          (SectionEditorForm {onSave: @save, onCancel: @cancel},
            (label {}, 'Model')
            (@select {name: 'embeddable_diy_emdedded_model[diy_model_id]', options: modelOptions})
          )
        else
          (div {className: 'ia-section-text'},
            if @props.data.name
              (div {},
                (div {}, @props.data.name)
                (img {src: @props.data.image_url})
              )
            else
              'No model selected'
          )
      )
