{iframe} = ReactFactories

modulejs.define 'components/common/interactive_iframe', [], () ->

  InteractiveIframe = createReactClass
    iframe: React.createRef()

    getInitialState: ->
      iframeId: 0

    getDefaultProps: ->
      src: ''
      width: '100%'
      height: '100%'
      initialAuthoredState: null
      onAuthoredStateChange: (authoredState) ->
      onSupportedFeaturesUpdate: (info) ->
      onHeightChange: (height) ->

    componentDidMount: ->
      @connect()

    componentWillUnmount: ->
      @disconnect()

    componentDidUpdate: (prevProps) ->
      # When iframe src is changed, we need to reinitialize iframe phone connection.
      @reload() if @props.src != prevProps.src

    reload: ->
      @disconnect()
      # We'll remove and add different iframe element because of the React's "key" property.
      # Theoretically we could also set .src again, but IframePhone doesn't support that well
      # (it won't send Hello msg again, so phone becomes partically disconnected).
      @setState iframeId: @state.iframeId + 1, =>
        @connect()

    connect: ->
      @iframePhone = new iframePhone.ParentEndpoint @iframe.current, @phoneAnswered
      @iframePhone.addListener 'authoredState', (authoredState) =>
        @props.onAuthoredStateChange(authoredState)
      @iframePhone.addListener 'supportedFeatures', (info) =>
        @props.onSupportedFeaturesUpdate(info)
      @iframePhone.addListener 'height', (info) =>
        @props.onHeightChange(info)

    disconnect: ->
      @iframePhone.disconnect()

    phoneAnswered: ->
      @iframePhone.post 'initInteractive', @props.initMsg

    render: ->
      { iframeId } = @state
      { src, width, height } = @props
      (iframe {ref: @iframe, src, width, height, key: iframeId, frameBorder: 'no', allowFullScreen: 'true'})
