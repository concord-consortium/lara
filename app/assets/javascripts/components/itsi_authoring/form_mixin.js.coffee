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
    return if $.isEmptyObject formData
    # Rails-specific approach to PUT requests.
    formData._method = 'PUT'
    $.ajax
      url: @updateUrl()
      data: formData
      type: 'POST',
      success: ->
        console.log 'component updated'
      error: ->
        console.log 'component update failed'

  input: (props) ->
    props.onChange = @handleFormChange
    input props

  textarea: (props) ->
    props.onChange = @handleFormChange
    textarea props

  saveButton: ->
    (div {className: 'ia-save-btn', onClick: @submitForm}, 'Save')
