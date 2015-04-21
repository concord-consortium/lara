describe 'MockIframePhone', ->
  describe 'when installed', ->
    beforeEach ->
      jasmine.mockIframePhone.install()
      $('<iframe>').appendTo 'body'
      @iframeEl = $('iframe')[0]
      # Test both types of endpoints.
      @parentEndpoint = new iframePhone.ParentEndpoint @iframeEl
      @iframeEndpoint = new iframePhone.getIFrameEndpoint()
      @phones = [@parentEndpoint, @iframeEndpoint]

    afterEach ->
      jasmine.mockIframePhone.uninstall()
      $('iframe').remove()

    it 'should provide iframePhone module that mimics the original one', ->
      @phones.forEach (phone) ->
        expect(phone).toEqual jasmine.anything()

    it 'should provide jasmine.mockIframePhone.postMessageFrom function', ->
      expect(typeof jasmine.mockIframePhone.postMessageFrom).toEqual 'function'

    it 'should provide jasmine.mockIframePhone.messages object', ->
      expect(typeof jasmine.mockIframePhone.messages).toEqual 'object'

    describe 'when fake message is posted *to* iframe phone', ->
      beforeEach ->
        @parentListener = jasmine.createSpy 'parentListener'
        @parentEndpoint.addListener 'testMsg', @parentListener
        jasmine.mockIframePhone.postMessageFrom @iframeEl, {type: 'testMsg', content: 'foobar'}

        @iframeListener = jasmine.createSpy 'iframeListener'
        @iframeEndpoint.addListener 'testMsg', @iframeListener
        jasmine.mockIframePhone.postMessageFrom window.parent, {type: 'testMsg', content: 'barfoo'}

      it 'listeners should be called', ->
        expect(@parentListener).toHaveBeenCalledWith 'foobar'
        expect(@parentListener.calls.count()).toEqual 1
        expect(@iframeListener).toHaveBeenCalledWith 'barfoo'
        expect(@iframeListener.calls.count()).toEqual 1

      it 'should be recorded', ->
        expect(jasmine.mockIframePhone.messages.count()).toEqual 2
        expect(jasmine.mockIframePhone.messages.at(0)).toEqual
          source: @iframeEl
          target: window
          message:
            type: 'testMsg'
            content: 'foobar'
        expect(jasmine.mockIframePhone.messages.at(1)).toEqual
          source: window.parent
          target: window
          message:
            type: 'testMsg'
            content: 'barfoo'

    describe 'when fake message is posted *from* iframe phone', ->
      beforeEach ->
        @parentEndpoint.post 'testMsgFromParentEndpoint', {key: 'value'}
        @iframeEndpoint.post 'testMsgFromIframeEndpoint', {param: 'test'}

      it 'it should be recorded', ->
        expect(jasmine.mockIframePhone.messages.count()).toEqual 2
        expect(jasmine.mockIframePhone.messages.at(0)).toEqual
          source: window
          target: @iframeEl
          message:
            type: 'testMsgFromParentEndpoint'
            content: {key: 'value'}
        expect(jasmine.mockIframePhone.messages.at(1)).toEqual
          source: window
          target: window.parent
          message:
            type: 'testMsgFromIframeEndpoint'
            content: {param: 'test'}

    describe 'jasmine.mockIframePhone.messages object', ->
      beforeEach ->
        jasmine.mockIframePhone.postMessageFrom window.parent, {type: 'testMsg1', content: 'barfoo'}
        jasmine.mockIframePhone.postMessageFrom @iframeEl, {type: 'testMsg2', content: 'foobar'}

      it 'should allow to count recorded messages', ->
        expect(jasmine.mockIframePhone.messages.count()).toEqual 2

      it 'should allow to get all messages', ->
        expect(jasmine.mockIframePhone.messages.all().length).toEqual 2

      it 'should allow to get specific message', ->
        expect(jasmine.mockIframePhone.messages.at(0)).toEqual jasmine.mockIframePhone.messages.all()[0]
        expect(jasmine.mockIframePhone.messages.at(0)).toEqual
          source: window.parent
          target: window
          message:
            type: 'testMsg1'
            content: 'barfoo'
        expect(jasmine.mockIframePhone.messages.at(1)).toEqual jasmine.mockIframePhone.messages.all()[1]
        expect(jasmine.mockIframePhone.messages.at(1)).toEqual
          source: @iframeEl
          target: window.parent
          message:
            type: 'testMsg2'
            content: 'foobar'

      it 'should allow to reset recorded messages', ->
        jasmine.mockIframePhone.messages.reset()
        expect(jasmine.mockIframePhone.messages.count()).toEqual 0

    describe 'MockPhone afterConnectedCallback support', ->
      it '(fake) connection is automatically initialized right after the parent endpoint is created (sync!)', ->
        afterConnectedCallback = jasmine.createSpy 'afterConnectedCallback'
        parentEndpoint = new iframePhone.ParentEndpoint @iframeEl, afterConnectedCallback
        expect(afterConnectedCallback).toHaveBeenCalled
        expect(afterConnectedCallback.calls.count()).toEqual 1

        # Test different constructor too.
        afterConnectedCallback.calls.reset()
        parentEndpoint = new iframePhone.ParentEndpoint @iframeEl, 'origin', afterConnectedCallback
        expect(afterConnectedCallback).toHaveBeenCalled
        expect(afterConnectedCallback.calls.count()).toEqual 1

    describe 'MockPhone#targetOrigin', ->
      describe 'of parent endpoint', ->
        it 'should return origin of an iframe', ->
          expect(@parentEndpoint.targetOrigin()).toEqual '' # no src defined for the default iframe

          iframeEl = $('<iframe src="http://test.com/path/foo">').appendTo 'body'
          parentEndpoint = new iframePhone.ParentEndpoint  iframeEl[0]
          expect(parentEndpoint.targetOrigin()).toEqual 'http://test.com'

      describe 'of iframe endpoint', ->
        it 'should return origin of the parent window', ->
          expect(@iframeEndpoint.targetOrigin()).toEqual window.parent.location.origin

      describe 'when origin is specified explicitly', ->
        it 'should be returned', ->
          iframeEl = $('<iframe>').appendTo 'body'
          parentEndpoint = new iframePhone.ParentEndpoint  iframeEl[0], 'some.origin.com'
          expect(parentEndpoint.targetOrigin()).toEqual 'some.origin.com'
