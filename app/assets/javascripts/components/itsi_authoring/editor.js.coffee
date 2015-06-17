{div} = React.DOM

modulejs.define 'components/itsi_authoring/editor',
[
  'components/itsi_authoring/metadata_editor',
  'components/itsi_authoring/section_editor'
],
(
  MetadataEditorClass,
  SectionEditorClass
) ->

  MetadataEditor = React.createFactory MetadataEditorClass
  SectionEditor = React.createFactory SectionEditorClass

  React.createClass

    render: ->
      (div {className: 'ia-editor'},
        (MetadataEditor {metadata: @props.metadata})
        (div {className: 'ia-editor-sections'},
          for section, i in @props.sections
            # ignore the 'Test page'
            if section.name isnt 'Test page'
              title = if name is 'Second Career STEM Question' then 'Concluding Career STEM Question' else section.name
              (SectionEditor {section: section, title: title, key: i})
        )
      )
