{div, input, textarea} = React.DOM

# Component that includes this mixin needs to define updateUrl() method.
modulejs.define 'components/itsi_authoring/form_mixin', ->
  getInitialState: ->
    changedData: {}

  handleFormChange: (e) ->
    changedData = @state.changedData
    changedData[e.target.name] = e.target.value
    @setState changedData: changedData

  submitForm: ->
    formData = @state.changedData
    # Don't issue request if nothing has been updated.
    if $.isEmptyObject formData
      @props.alert 'warn', 'No changes to save'
      return
    # Rails-specific approach to PUT requests.
    formData._method = 'PUT'
    $.ajax
      url: @updateUrl()
      data: formData
      type: 'POST',
      success: =>
        @props.alert 'info', 'Saved'
        @setState changedData: {}
      error: =>
        @props.alert 'error', 'Save Failed!'

  input: (props) ->
    props.onChange = @handleFormChange
    input props

  textarea: (props) ->
    props.onChange = @handleFormChange
    textarea props

  saveButton: ->
    (div {className: 'ia-save-btn', onClick: @submitForm}, 'Save')
