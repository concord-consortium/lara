{textarea, input, select, option} = ReactFactories

# Mixin that provides helper methods to build dynamic form which can be udpated and saved without page reload.
# Component that includes this mixin needs to define @updateUrl property.
modulejs.define 'components/common/ajax_form_mixin',
[
  'components/common/rich_text_editor'
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
    else
      for key, value of @props.data
        values[key] = value
        defaultValues[key] = value

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
      if key == 'managed_interactive_open_response[prompt]'
        default_answer = @state.values['managed_interactive_open_response[default_text]']
        authored_state = '{"version":1,"questionType":"open_response","prompt":"' + value + '","defaultAnswer":" ' + default_answer + '"}'
        @valueChanged 'managed_interactive[authored_state]', authored_state
      defaultValues[key] = value
    @setState
      edit: false
      defaultValues: defaultValues

    # Don't issue request if nothing has been updated.
    if $.isEmptyObject @state.changedValues
      @props.alert? 'warn', 'No changes to save'
      return

    # Rails-specific approach to PUT requests.
    @state.changedValues._method = 'PUT'
    $.ajax
      url: "#{@props.updateUrl || @props.data.update_url}.json" # two formats available
      data: @state.changedValues
      type: 'POST',
      success: =>
        @props.alert? 'info', 'Saved'
        @setState changedValues: {}
      error: (xhr, textStatus, errorThrown) =>
        @props.alert? 'error', 'Save Failed!'

  valueChanged: (key, value, setStateCallback = null) ->
    @state.values[key] = value
    @state.changedValues[key] = value
    @setState {values: @state.values, changedValues: @state.changedValues}, setStateCallback

  _handleChange: (key, value, onChange) ->
    @valueChanged key, value
    onChange? key, value

  richText: (options) ->
    changed = (newText) =>
      @_handleChange options.name, newText, options.onChange
    RichTextEditor {name: options.name, text: @state.values[options.name], TinyMCEConfig: options.TinyMCEConfig, onChange: changed}

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

  checkbox: (options) ->
    changed = (e) =>
      @_handleChange options.name, e.target.checked, options.onChange
    input {type: 'checkbox', name: options.name, checked: @state.values[options.name], onChange: changed}
