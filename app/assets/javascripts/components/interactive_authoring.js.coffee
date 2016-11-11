{iframe} = React.DOM

modulejs.define 'components/interactive_authoring', [], () ->

  InteractiveAuthoring = React.createClass
    getInitialState: ->
      authoredState: null

    componentDidMount: ->
      @iframePhone = IframePhoneManager.getPhone(@refs.iframe.getDOMNode(), @phoneAnswered)
      @iframePhone.addListener 'authoredState', (authoredState) =>
        @props.onAuthoredStateChange(authoredState)

    componentWillUnmount: ->
      @iframePhone.disconnect()

    phoneAnswered: ->
      @iframePhone.post 'initInteractive',
        version: 1
        error: null
        mode: 'authoring'
        authoredState: @props.authoredState

    render: ->
      { src } = @props
      (iframe {ref: 'iframe', src: src, width: '100%', height: '100%', frameBorder: 'no', allowFullScreen: 'true'})
