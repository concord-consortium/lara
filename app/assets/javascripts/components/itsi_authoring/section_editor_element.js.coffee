{div, label, input, span, a} = React.DOM

modulejs.define 'components/itsi_authoring/section_editor_element',
[],
->

  React.createClass

    getInitialState: ->
      selected: not @props.data.is_hidden

    selected: (e) ->
      selected = e.target.checked
      postData =
        _method: 'PUT'
      postData[@props.toHide] = if selected then 0 else 1
      $.ajax
        url: "#{@props.data.update_url}.json"
        type: 'POST'
        data: postData
        success: =>
          @props.alert 'info', 'Saved'
        error: =>
          @props.alert 'error', 'Save Failed!'
      @setState selected: selected

    edit: (e) ->
      e.preventDefault()
      @props.onEdit()

    render: ->
      (div {className: 'ia-section-editor-element'},
        if @state.selected && @props.onEdit?
          (div {style: {float: 'right'}},
            (a {href: '#', className: 'ia-section-editor-edit', onClick: @edit}, 'edit')
          )
        (label {},
          (input {type: 'checkbox', ref: 'checkbox', checked: @state.selected, onChange: @selected})
          (span {className: 'ia-section-editor-title'}, @props.title)
        )
        (div {className: 'ia-section-editor-elements', style: {display: if @state.selected then 'block' else 'none'}},
          @props.children
        )
      )
