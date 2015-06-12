{div, input, textarea} = React.DOM

modulejs.define 'components/itsi_authoring/metadata_editor',
['components/itsi_authoring/form_mixin'],
(FormMixin) ->

  React.createClass
    mixins: [FormMixin]

    render: ->
      data = @props.initialData
      (div {className: 'ia-metadata-editor'},
        (div {className: 'ia-label'}, 'Activity name')
        (input type: 'text', name: 'lightweight_activity[name]', defaultValue: data.name, onChange: @handleFormChange)
        (div {className: 'ia-label'}, 'Activity description')
        (textarea name: 'lightweight_activity[description]', defaultValue: data.description, onChange: @handleFormChange)
        (div {className: 'ia-label'},
          @renderSaveButton()
        )
      )
