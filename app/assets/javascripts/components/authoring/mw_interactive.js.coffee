{div, input, b, i} = React.DOM

modulejs.define 'components/authoring/mw_interactive',
[
  'components/common/interactive_iframe',
],
(
  InteractiveIframeClass,
) ->

  InteractiveIframe = React.createFactory InteractiveIframeClass

  MwInteractive = React.createClass
    getInitialState: ->
      authoredState = @props.interactive.authored_state
      {
        authoringSupported: false
        authoredState: if typeof authoredState == 'string' then JSON.parse(authoredState) else authoredState
        modified: false
        saving: false
        message: ''
      }

    componentDidMount: ->
      window.addEventListener 'beforeunload', @onBeforeUnload

    componentWillUnmount: ->
      window.removeEventListener 'beforeunload', @onBeforeUnload

    onBeforeUnload: (e) ->
      { modified } = @state
      if modified
        e.returnValue = 'Authorable interactive state has not been saved.' +
                        'Are you sure you want to leave this page?'
      return e

    handleAuthoredStateChange: (authoredState) ->
      @setState {authoredState, modified: true}

    handleSupportedFeatures: (info) ->
      @setState {authoringSupported: !!info.features.authoredState}
      if (info.features.aspectRatio?)
        iframe = @refs.interactive.getDOMNode()
        iframe.style.height = Math.round(iframe.offsetWidth / info.features.aspectRatio) + 'px'

    save: ->
      data = {
        # Rails-specific approach to PUT requests.
        '_method': 'PUT',
        'mw_interactive[authored_state]': JSON.stringify(@state.authoredState)
      }
      @notify 'Saving...', true
      $.ajax
        url: "#{@props.updateUrl}.json"
        data: data
        type: 'POST',
        success: =>
          @notify 'Saved', false
          @setState modified: false
        error: (xhr, textStatus, errorThrown) =>
          @notify 'Error! Please try again', false
          console.error 'Error while saving authored state', errorThrown

    reset: ->
      @setState authoredState: null, =>
        # Save empty state.
        @save()
        # Reload iframe to initialize it with a new, empty state.
        @refs.interactive.reload()

    notify: (message, working) ->
      @setState {message: message, working: working}
      unless working
        setTimeout =>
          @setState message: ''
        , 1200

    render: ->
      { modified, authoringSupported, authoredState, message, working } = @state
      { interactive } = @props
      (div {className: 'authoring-mw-interactive'},
        (div {className: "status #{if authoringSupported then 'visible' else ''}"},
          'This interactive supports authoring'
          (input {type: 'button', className: 'save-btn', value: 'Save authored state', onClick: @save, disabled: working}) if modified
          (input {type: 'button', className: 'reset-btn', value: 'Reset authored state', onClick: @reset}) if authoredState
          (div {className: 'alert'},
            (i {className: 'fa fa-spinner fa-spin'}) if working
            (b {}, message)
          )
        )
        (InteractiveIframe
          ref: 'interactive'
          src: interactive.url
          initMsg: {
            version: 1
            error: null
            mode: 'authoring'
            authoredState: authoredState
          }
          onAuthoredStateChange: @handleAuthoredStateChange
          onSupportedFeaturesUpdate: @handleSupportedFeatures
        )
      )
