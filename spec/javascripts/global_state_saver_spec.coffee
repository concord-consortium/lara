describe 'GlobalIframeSaver', ->
  beforeEach ->
    loadFixtures "global-iframe-saver.html" # just 3 iframes
    jasmine.Ajax.install()
    jasmine.mockIframePhone.install()
    @saveUrl = 'https://lara.url/global_state_endpoint'
    @globalState = {key: 'val'}

  afterEach ->
    jasmine.Ajax.uninstall()
    jasmine.mockIframePhone.uninstall()

  it 'should broadcast global state if it is provided in config', ->
    @globalSaver = new GlobalIframeSaver save_url: @saveUrl, raw_data: JSON.stringify(@globalState)

    $('iframe').each (idx, iframeEl) =>
      @globalSaver.addNewInteractive(iframeEl)

    expect(jasmine.mockIframePhone.messages.count()).toEqual 3
    $('iframe').each (idx, iframeEl) =>
      expect(jasmine.mockIframePhone.messages.at(idx)).toEqual
        source: window
        target: iframeEl
        message:
          type: 'loadInteractiveGlobal'
          content: @globalState

  describe 'when "interactiveStateGlobal" message is received from iframe', ->
    beforeEach ->
      @globalSaver = new GlobalIframeSaver save_url: @saveUrl

      $('iframe').each (idx, iframeEl) =>
        @globalSaver.addNewInteractive(iframeEl)

      jasmine.mockIframePhone.postMessageFrom $('iframe')[0], {type: 'interactiveStateGlobal', content: @globalState}

    it 'should broadcast "loadInteractiveGlobal" to other iframes', ->
      expect(jasmine.mockIframePhone.messages.count()).toEqual 3
      # Initial message.
      expect(jasmine.mockIframePhone.messages.at(0)).toEqual
        source: $('iframe')[0]
        target: window
        message:
          type: 'interactiveStateGlobal'
          content: @globalState
      # Messages posted by GlobalIframeSaver:
      expect(jasmine.mockIframePhone.messages.at(1)).toEqual
        source: window
        target: $('iframe')[1]
        message:
          type: 'loadInteractiveGlobal'
          content: @globalState
      expect(jasmine.mockIframePhone.messages.at(2)).toEqual
        source: window
        target: $('iframe')[2]
        message:
          type: 'loadInteractiveGlobal'
          content: @globalState

    it 'should send state to LARA server', ->
      request = jasmine.Ajax.requests.mostRecent()
      expect(request.url).toBe @saveUrl
      expect(request.method).toBe 'POST'
      # No idea why raw data needs to be wrapped in array - caused by jQuery or MockAjax?
      expect(request.data()).toEqual raw_data: [JSON.stringify(@globalState)]
