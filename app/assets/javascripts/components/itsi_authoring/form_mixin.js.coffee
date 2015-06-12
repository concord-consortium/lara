{div} = React.DOM

# Component that includes this mixin needs to define @updateUrl property.
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
      url: @props.updateUrl
      data: formData
      type: 'POST',
      success: ->
        console.log 'component updated'
      error: ->
        console.log 'component update failed'

  renderSaveButton: ->
    (div {className: 'ia-save-btn', onClick: @submitForm}, 'Save')