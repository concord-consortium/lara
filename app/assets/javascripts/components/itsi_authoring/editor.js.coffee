{div} = React.DOM

modulejs.define 'components/itsi_authoring/editor',
['components/itsi_authoring/metadata_editor'],
(MetadataEditor) ->
  MetadataEditor = React.createFactory MetadataEditor

  React.createClass
    render: ->
      (div {className: 'ia-editor'},
        (MetadataEditor initialData: @props.metadata, updateUrl: @props.paths.activity)
      )
