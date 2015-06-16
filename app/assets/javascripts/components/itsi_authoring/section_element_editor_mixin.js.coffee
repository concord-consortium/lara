{textarea, input, select, option} = React.DOM

# Component that includes this mixin needs to define @updateUrl property.
modulejs.define 'components/itsi_authoring/section_element_editor_mixin',
[
  'components/itsi_authoring/rich_text_editor'
],
(
  RichTextEditorClass
) ->

  RichTextEditor = React.createFactory RichTextEditorClass

  getInitialState: ->
    values = {}
    defaultValues = {}
    if @dataMap
      for key, value of @dataMap
        values[key] = @props.data[value]
        defaultValues[key] = @props.data[value]

    initialState =
      edit: @initialEditState?()
      values: values
      defaultValues: defaultValues
      changedValues: {}

  edit: (e) ->
    e?.preventDefault?()
    @setState edit: true

  cancel: (e) ->
    e?.preventDefault?()
    values = {}
    for key, value of @state.defaultValues
      values[key] = value
    @setState
      edit: false
      values: values

  save: (e) ->
    e?.preventDefault?()
    defaultValues = {}
    for key, value of @state.values
      defaultValues[key] = value
    @setState
      edit: false
      defaultValues: defaultValues

    # Don't issue request if nothing has been updated.
    return if $.isEmptyObject @state.changedValues

    # Rails-specific approach to PUT requests.
    @state.changedValues._method = 'PUT'
    $.ajax
      url: "#{@props.data.update_url}.json"
      data: @state.changedValues
      type: 'POST',
      success: ->
        console.log 'component updated'
      error: ->
        console.log 'component update failed'

  _handleChange: (key, value) ->
    @state.values[key] = value
    @state.changedValues[key] = value
    @setState
      values: @state.values
      changedValues: @state.changedValues

  richText: (options) ->
    changed = (newText) =>
      @_handleChange options.name, newText
    RichTextEditor {name: options.name, text: @state.values[options.name], onChange: changed}

  text: (options) ->
    changed = (e) =>
      @_handleChange options.name, e.target.value
    input {type: 'text', name: options.name, value: @state.values[options.name], onChange: changed}

  select: (options) ->
    changed = (e) =>
      @_handleChange options.name, e.target.value
    (select {'text', name: options.name, value: @state.values[options.name], onChange: changed},
      for name, value in options.options
        (option {name: name, value: value, key: name})
    )
