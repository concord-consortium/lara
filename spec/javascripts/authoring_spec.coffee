describe "Authoring components", () ->

  describe "interactive_iframe", ->
    fakePhone = jasmine.createSpyObj('iframePhone', ['post', 'addListener'])
    originalParentEndpoint = window.iframePhone.ParentEndpoint
    beforeEach () ->
      window.iframePhone.ParentEndpoint = () ->
        return fakePhone
    afterEach () ->
      window.iframePhone.ParentEndpoint = originalParentEndpoint

    it "loads iframe", ->
      props = {}
      interactive = jasmine.react.renderComponent "authoring/interactive_iframe", props
      iframe = jasmine.react.findTag interactive, "iframe"
      expect(iframe).not.toBe(null)

    it "sends initInteractive message to iframe", ->
      props =
        initialAuthoredState: {test: 123}
      interactive = jasmine.react.renderComponent "authoring/interactive_iframe", props
      interactive.phoneAnswered()
      expect(fakePhone.post).toHaveBeenCalledWith('initInteractive', {
        version: 1,
        error: null,
        mode: 'authoring',
        authoredState: {test: 123}
      })

  describe "mw_interactive", ->
    it "loads interactive", ->
      props =
        interactive:
          url: 'test-model.txt'
          authored_state: null
      mwInteractive = jasmine.react.renderComponent "authoring/mw_interactive", props
      iframe = jasmine.react.findComponent mwInteractive, "authoring/interactive_iframe"
      expect(iframe).not.toBe(null)

    it "saves updated authored state", ->
      props =
        updateUrl: "fake_update_url"
        interactive:
          url: 'test-model.txt'
          authored_state: null
      mwInteractive = jasmine.react.renderComponent "authoring/mw_interactive", props
      mwInteractive.handleAuthoredStateChange({test: 123})
      request = jasmine.react.captureRequest ->
        jasmine.react.click (jasmine.react.findClass mwInteractive, "save-btn")
      expect(request.url).toBe("fake_update_url.json")
      expect(request.params).toBe("_method=PUT&mw_interactive%5Bauthored_state%5D=%7B%22test%22%3A123%7D")
