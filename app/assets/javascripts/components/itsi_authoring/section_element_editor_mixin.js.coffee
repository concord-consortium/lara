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
    if $.isEmptyObject @state.changedValues
      @props.alert 'warn', 'No changes to save'
      return

    # Rails-specific approach to PUT requests.
    @state.changedValues._method = 'PUT'
    $.ajax
      url: "#{@props.data.update_url}.json"
      data: @state.changedValues
      type: 'POST',
      success: =>
        @props.alert 'info', 'Saved'
        @setState changedValues: {}
      error: (xhr, textStatus, errorThrown) =>
        @props.alert 'error', 'Save Failed!'

  valueChanged: (key, value) ->
    @state.values[key] = value
    @state.changedValues[key] = value

  _handleChange: (key, value, onChange) ->
    @valueChanged key, value
    onChange? key, value
    @setState @state

  richText: (options) ->
    changed = (newText) =>
      @_handleChange options.name, newText, options.onChange
    RichTextEditor {name: options.name, text: @state.values[options.name], onChange: changed}

  text: (options) ->
    changed = (e) =>
      @_handleChange options.name, e.target.value, options.onChange
    input {type: 'text', name: options.name, value: @state.values[options.name], onChange: changed}

  textarea: (options) ->
    changed = (e) =>
      @_handleChange options.name, e.target.value, options.onChange
    textarea {name: options.name, value: @state.values[options.name], onChange: changed}

  select: (options) ->
    changed = (e) =>
      @_handleChange options.name, e.target.value, options.onChange
    (select {'text', name: options.name, value: @state.values[options.name], onChange: changed},
      for item in options.options
        (option {value: item.value, key: item.name}, item.name)
    )
