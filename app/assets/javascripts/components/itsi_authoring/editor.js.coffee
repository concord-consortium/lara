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

  class Section
    constructor: (@name, @data, @selected) -> undefined

  React.createClass
    getInitialState: ->
      sectionsByName = {}

      # add the existing sections
      for section in @props.sections
        sectionsByName[section.name] = new Section section.name, section, true

      # add any missing default sections
      for sectionName in ['Introduction', 'Second Career STEM Question']
        sectionsByName[sectionName] ||= new Section sectionName, {}, true

      # add any missing non-default sections
      otherSectionNames = [
        'Standards'
        'Career STEM Question'
        'Materials'
        'Safety'
        'Procedure'
        'Prediction I'
        'Collect Data I'
        'Prediction II'
        'Collect Data II'
        'Prediction III'
        'Collect Data III'
        'Analysis'
        'Conclusion'
        'Prediction IV'
        'Further Investigation'
      ]
      for sectionName in otherSectionNames
        sectionsByName[sectionName] ||= new Section sectionName, {}, false

      initialState =
        sectionsByName: sectionsByName

    addSection: (name, data) ->
      sectionsByName[name] = data

    renderSection: (options) ->
      title = if options.hasOwnProperty('title') then options.title else options.name
      (SectionEditor {name: options.name, title: title, section: @state.sectionsByName[options.name], elements: options.elements, updateUrl: @props.paths.activity})

    renderCareerSTEMQuestion: (options) ->
      options.elements = [
        SectionEditorClass.OpenResponseQuestion
        SectionEditorClass.OpenResponseQuestion
      ]
      (@renderSection options)

    renderPrediction: (options) ->
      options.elements = [
        SectionEditorClass.Sensor
        SectionEditorClass.DrawingResponse
        SectionEditorClass.OpenResponseQuestion
      ]
      (@renderSection options)

    renderCollectData: (options) ->
      options.elements = [
        SectionEditorClass.Sensor
        SectionEditorClass.Model
        SectionEditorClass.OpenResponseQuestion
        SectionEditorClass.OpenResponseQuestion
        SectionEditorClass.DrawingResponse
      ]
      (@renderSection options)

    render: ->
      (div {className: 'ia-editor'},
        (MetadataEditor {metadata: @props.metadata, updateUrl: @props.paths.activity})
        (div {className: 'ia-editor-sections'},
          (@renderSection {name: 'Introduction', elements: [
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.DrawingResponse
          ], selectedByDefault: true})
          (@renderSection {name: 'Standards', elements: []})
          (@renderCareerSTEMQuestion {name: 'Career STEM Question'})
          (@renderSection {name: 'Materials', elements: []})
          (@renderSection {name: 'Safety', elements: []})
          (@renderSection {name: 'Procedure', elements: [
            SectionEditorClass.DrawingResponse
          ]})
          (@renderPrediction {name: 'Prediction I'})
          (@renderCollectData {name: 'Collect Data I'})
          (@renderPrediction {name: 'Prediction II'})
          (@renderCollectData {name: 'Collect Data II'})
          (@renderPrediction {name: 'Prediction III'})
          (@renderCollectData {name: 'Collect Data III'})
          (@renderSection {name: 'Analysis', elements: [
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.DrawingResponse
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.OpenResponseQuestion
          ]})
          (@renderSection {name: 'Conclusion', elements: [
            SectionEditorClass.OpenResponseQuestion
            SectionEditorClass.DrawingResponse
          ]})
          (@renderCareerSTEMQuestion {name: 'Second Career STEM Question', title: 'Concluding Career STEM Question', selectedByDefault: true})
          (@renderPrediction {name: 'Prediction IV'})
          (@renderCollectData {name: 'Further Investigation'})
        )
      )

