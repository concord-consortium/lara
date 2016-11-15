{iframe} = React.DOM

modulejs.define 'components/authoring/interactive_iframe', [], () ->

  InteractiveIframe = React.createClass
    getInitialState: ->
      iframeId: 0

    getDefaultProps: ->
      src: ''
      initialAuthoredState: null
      onAuthoredStateChange: (authoredState) ->

    componentDidMount: ->
      @connect()

    componentWillUnmount: ->
      @disconnect()

    reload: ->
      @disconnect()
      # We'll remove and add different iframe element because of the React's "key" property.
      # Theoretically we could also set .src again, but IframePhone doesn't support that well
      # (it won't send Hello msg again, so phone becomes partically disconnected).
      @setState iframeId: @state.iframeId + 1, =>
        @connect()

    connect: ->
      @iframePhone = IframePhoneManager.getPhone(@refs.iframe.getDOMNode(), @phoneAnswered)
      @iframePhone.addListener 'authoredState', (authoredState) =>
        @props.onAuthoredStateChange(authoredState)

    disconnect: ->
      @iframePhone.disconnect()

    phoneAnswered: ->
      authoredState = if typeof @props.initialAuthoredState == 'string'
                        JSON.parse(@props.initialAuthoredState)
                      else
                        @props.initialAuthoredState
      @iframePhone.post 'initInteractive',
        version: 1
        error: null
        mode: 'authoring'
        authoredState: authoredState

    render: ->
      { iframeId } = @state
      { src } = @props
      (iframe {ref: 'iframe', key: iframeId, src: src, width: '100%', height: '100%', frameBorder: 'no', allowFullScreen: 'true'})
