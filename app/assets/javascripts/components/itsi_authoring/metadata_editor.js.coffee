{div} = React.DOM

modulejs.define 'components/itsi_authoring/metadata_editor',
['components/itsi_authoring/form_mixin'],
(FormMixin) ->

  React.createClass
    mixins: [FormMixin]

    updateUrl: ->
      @props.metadata.update_url

    render: ->
      (div {className: 'ia-metadata-editor'},
        (div {className: 'ia-label'}, 'Activity name')
        (@input {type: 'text', name: 'lightweight_activity[name]', defaultValue: @props.metadata.name})
        (div {className: 'ia-label'}, 'Activity description')
        (@textarea {name: 'lightweight_activity[description]', defaultValue: @props.metadata.description})
        (div {className: 'ia-label'},
          @saveButton()
        )
      )
