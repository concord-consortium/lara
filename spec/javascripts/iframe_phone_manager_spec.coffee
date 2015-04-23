describe 'IframePhoneManager', ->
  beforeEach ->
    setFixtures '<iframe src="http://test.com"></iframe>'
    @iframeEl = $('iframe')[0]

  it 'is available in global namespace', ->
    expect(IframePhoneManager).toEqual jasmine.anything()

  describe '#getPhone', ->
    it 'returns the same phone even if called multiple times', ->
      phone1 = IframePhoneManager.getPhone @iframeEl
      phone2 = IframePhoneManager.getPhone @iframeEl
      expect(phone1).toBe phone2

    it 'executes all provided afterConnectedCallbacks (async!)', (done) ->
      jasmine.mockIframePhone.withMock =>
        jasmine.mockIframePhone.autoConnect = false

        callback = jasmine.createSpy 'callback'
        IframePhoneManager.getPhone @iframeEl, callback
        phone = IframePhoneManager.getPhone @iframeEl, callback
        expect(callback).not.toHaveBeenCalled()
        setTimeout =>
          phone.fakeConnection()
          # Callbacks added before connection was initialized should be executed right away when it happens
          # (in real world it's async).
          expect(callback).toHaveBeenCalled()
          expect(callback.calls.count()).toEqual 2
          # Callbacks added after connection was initialized should be executed asynchronously in the future
          # (so we're consistent and we always simulate async connection to an iframe).
          callback.calls.reset()
          IframePhoneManager.getPhone @iframeEl, callback
          expect(callback).not.toHaveBeenCalled()
          # Test passes only if done is called within next 5 seconds.
          IframePhoneManager.getPhone @iframeEl, done
        , 1

    describe '#getRpcEndpoint', ->
      it 'returns the same RPC endpoint even if called multiple times', ->
        rpc1 = IframePhoneManager.getRpcEndpoint @iframeEl, 'test-namespace'
        rpc2 = IframePhoneManager.getRpcEndpoint @iframeEl, 'test-namespace'
        expect(rpc1).toBe rpc2

      it 'returns different RPC endpoint for different namespaces', ->
        rpc1 = IframePhoneManager.getRpcEndpoint @iframeEl, 'test-namespace-1'
        rpc2 = IframePhoneManager.getRpcEndpoint @iframeEl, 'test-namespace-2'
        expect(rpc1).not.toBe rpc2
