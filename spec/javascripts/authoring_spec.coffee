describe "Authoring components", () ->
  iframePhone = jasmine.mockIframePhone
  beforeEach () ->
    iframePhone.install()
    iframePhone.autoConnect = false
  afterEach () ->
    iframePhone.uninstall()

  describe "interactive_iframe", ->
    it "loads iframe", ->
      props = {}
      interactive = jasmine.react.renderComponent "common/interactive_iframe", props
      iframe = jasmine.react.findTag interactive, "iframe"
      expect(iframe).not.toBe(null)

    it "sends 'initInteractive' message to iframe", () ->
      props =
        initMsg: {
          version: 1,
          error: null,
          mode: 'authoring',
          authoredState: {test: 123}
        }
      jasmine.react.renderComponent "common/interactive_iframe", props
      iframePhone.connect()
      # initInteractive should be called right after connection.
      expect(iframePhone.messages.findType('initInteractive').message.content).toEqual({
        version: 1,
        error: null,
        mode: 'authoring',
        authoredState: {test: 123}
      })

    it "handles various LARA Interactive API messages", () ->
      props =
        onAuthoredStateChange: ->
        onSupportedFeaturesUpdate: ->
        onHeightChange: ->
      spyOn(props, 'onAuthoredStateChange')
      spyOn(props, 'onSupportedFeaturesUpdate')
      spyOn(props, 'onHeightChange')

      interactive = jasmine.react.renderComponent "common/interactive_iframe", props
      iframePhone.connect()
      iframe = ReactDOM.findDOMNode(jasmine.react.findTag(interactive, "iframe"))

      iframePhone.postMessageFrom(iframe, {type: "authoredState", content: {test: 123}})
      expect(props.onAuthoredStateChange).toHaveBeenCalledWith({test: 123})

      iframePhone.postMessageFrom(iframe, {type: "supportedFeatures", content: {test: 321}})
      expect(props.onSupportedFeaturesUpdate).toHaveBeenCalledWith({test: 321})

      iframePhone.postMessageFrom(iframe, {type: "height", content: {1000}})
      expect(props.onHeightChange).toHaveBeenCalledWith(1000)

  describe "mw_interactive", ->
    it "loads interactive using InteractiveIframe component", ->
      props =
        interactive:
          url: 'test-model.txt'
          authored_state: null
      mwInteractive = jasmine.react.renderComponent "authoring/mw_interactive", props
      iframe = jasmine.react.findComponent mwInteractive, "common/interactive_iframe"
      expect(iframe).not.toBe(null)

    it "saves updated authored state", ->
      props =
        updateUrl: "fake_update_url"
        interactive:
          url: 'test-model.txt'
          authored_state: null
      mwInteractive = jasmine.react.renderComponent "authoring/mw_interactive", props
      interactive = jasmine.react.findComponent mwInteractive, "common/interactive_iframe"
      interactive.props.onAuthoredStateChange({test: 123})

      request = jasmine.react.captureRequest ->
        jasmine.react.click (jasmine.react.findClass mwInteractive, "save-btn")
      expect(request.url).toBe("fake_update_url.json")
      expect(request.params).toBe("_method=PUT&mw_interactive%5Bauthored_state%5D=%7B%22test%22%3A123%7D")

    it "resets authored state", ->
      props =
        updateUrl: "fake_update_url"
        interactive:
          url: 'test-model.txt'
          authored_state: {test: 123}
      mwInteractive = jasmine.react.renderComponent "authoring/mw_interactive", props

      request = jasmine.react.captureRequest ->
        jasmine.react.click (jasmine.react.findClass mwInteractive, "reset-btn")
      expect(request.url).toBe("fake_update_url.json")
      expect(request.params).toBe("_method=PUT&mw_interactive%5Bauthored_state%5D=null")
