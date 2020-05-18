describe("MockIframePhone", () => {
  it("TODO", () => {
    expect(true).toBe(true);
  });
});

/*
describe('MockIframePhone', () => describe('when installed', function() {
  beforeEach(function() {
    jasmine.mockIframePhone.install();
    $('<iframe>').appendTo('body');
    this.iframeEl = $('iframe')[0];
    // Test both types of endpoints.
    this.parentEndpoint = new iframePhone.ParentEndpoint(this.iframeEl);
    this.iframeEndpoint = new iframePhone.getIFrameEndpoint();
    return this.phones = [this.parentEndpoint, this.iframeEndpoint];});

  afterEach(function() {
    jasmine.mockIframePhone.uninstall();
    return $('iframe').remove();
  });

  it('should provide iframePhone module that mimics the original one', function() {
    return this.phones.forEach(phone => expect(phone).toEqual(jasmine.anything()));
  });

  it('should provide jasmine.mockIframePhone.postMessageFrom function', () => {
    expect(typeof jasmine.mockIframePhone.postMessageFrom).toEqual('function'));
  });

  it('should provide jasmine.mockIframePhone.messages object', () => {
    expect(typeof jasmine.mockIframePhone.messages).toEqual('object'));
  });

  describe('when fake message is posted *to* iframe phone', function() {
    beforeEach(function() {
      this.parentListener = jasmine.createSpy('parentListener');
      this.parentEndpoint.addListener('testMsg', this.parentListener);
      jasmine.mockIframePhone.postMessageFrom(this.iframeEl, {type: 'testMsg', content: 'foobar'});

      this.iframeListener = jasmine.createSpy('iframeListener');
      this.iframeEndpoint.addListener('testMsg', this.iframeListener);
      return jasmine.mockIframePhone.postMessageFrom(window.parent, {type: 'testMsg', content: 'barfoo'});});

    it('listeners should be called', function() {
      expect(this.parentListener).toHaveBeenCalledWith('foobar');
      expect(this.parentListener.calls.count()).toEqual(1);
      expect(this.iframeListener).toHaveBeenCalledWith('barfoo');
      return expect(this.iframeListener.calls.count()).toEqual(1);
    });

    return it('should be recorded', function() {
      expect(jasmine.mockIframePhone.messages.count()).toEqual(2);
      expect(jasmine.mockIframePhone.messages.at(0)).toEqual({
        source: this.iframeEl,
        target: window,
        message: {
          type: 'testMsg',
          content: 'foobar'
        }
      });
      return expect(jasmine.mockIframePhone.messages.at(1)).toEqual({
        source: window.parent,
        target: window,
        message: {
          type: 'testMsg',
          content: 'barfoo'
        }
      });
    });
  });

  describe('when fake message is posted *from* iframe phone', function() {
    beforeEach(function() {
      this.parentEndpoint.post('testMsgFromParentEndpoint', {key: 'value'});
      return this.iframeEndpoint.post('testMsgFromIframeEndpoint', {param: 'test'});});

    return it('it should be recorded', function() {
      expect(jasmine.mockIframePhone.messages.count()).toEqual(2);
      expect(jasmine.mockIframePhone.messages.at(0)).toEqual({
        source: window,
        target: this.iframeEl,
        message: {
          type: 'testMsgFromParentEndpoint',
          content: {key: 'value'}
        }});
      return expect(jasmine.mockIframePhone.messages.at(1)).toEqual({
        source: window,
        target: window.parent,
        message: {
          type: 'testMsgFromIframeEndpoint',
          content: {param: 'test'}
        }});
  });
});

  describe('jasmine.mockIframePhone.messages object', function() {
    beforeEach(function() {
      jasmine.mockIframePhone.postMessageFrom(window.parent, {type: 'testMsg1', content: 'barfoo'});
      return jasmine.mockIframePhone.postMessageFrom(this.iframeEl, {type: 'testMsg2', content: 'foobar'});});

    it('should allow to count recorded messages', () => expect(jasmine.mockIframePhone.messages.count()).toEqual(2));

    it('should allow to get all messages', () => expect(jasmine.mockIframePhone.messages.all().length).toEqual(2));

    it('should allow to get specific message', function() {
      expect(jasmine.mockIframePhone.messages.at(0)).toEqual(jasmine.mockIframePhone.messages.all()[0]);
      expect(jasmine.mockIframePhone.messages.at(0)).toEqual({
        source: window.parent,
        target: window,
        message: {
          type: 'testMsg1',
          content: 'barfoo'
        }
      });
      expect(jasmine.mockIframePhone.messages.at(1)).toEqual(jasmine.mockIframePhone.messages.all()[1]);
      return expect(jasmine.mockIframePhone.messages.at(1)).toEqual({
        source: this.iframeEl,
        target: window.parent,
        message: {
          type: 'testMsg2',
          content: 'foobar'
        }
      });
    });

    return it('should allow to reset recorded messages', function() {
      jasmine.mockIframePhone.messages.reset();
      return expect(jasmine.mockIframePhone.messages.count()).toEqual(0);
    });
  });

  describe('MockPhone afterConnectedCallback support', function() {
    describe('when jasmine.mockIframePhone.autoConnect is set to true (default)', () => {
      it('(fake) connection is automatically initialized', function() {
        const afterConnectedCallback = jasmine.createSpy('afterConnectedCallback');
        let parentEndpoint = new iframePhone.ParentEndpoint(this.iframeEl, afterConnectedCallback);
        expect(afterConnectedCallback).toHaveBeenCalled();
        expect(afterConnectedCallback.calls.count()).toEqual(1);
        // Test different constructor too.
        afterConnectedCallback.calls.reset();
        parentEndpoint = new iframePhone.ParentEndpoint(this.iframeEl, 'origin', afterConnectedCallback);
        expect(afterConnectedCallback).toHaveBeenCalled;
        return expect(afterConnectedCallback.calls.count()).toEqual(1);
      })});

    return describe('when jasmine.mockIframePhone.autoConnect is set to false', function() {
      beforeEach(() => jasmine.mockIframePhone.autoConnect = false);

      return it('(fake) connection needs to be manually initialized', function() {
        const afterConnectedCallback = jasmine.createSpy('afterConnectedCallback');
        let parentEndpoint = new iframePhone.ParentEndpoint(this.iframeEl, afterConnectedCallback);
        expect(afterConnectedCallback).not.toHaveBeenCalled();
        parentEndpoint.fakeConnection();
        expect(afterConnectedCallback).toHaveBeenCalled();
        expect(afterConnectedCallback.calls.count()).toEqual(1);
        // Test different constructor too.
        afterConnectedCallback.calls.reset();
        parentEndpoint = new iframePhone.ParentEndpoint(this.iframeEl, 'origin', afterConnectedCallback);
        expect(afterConnectedCallback).not.toHaveBeenCalled();
        parentEndpoint.fakeConnection();
        expect(afterConnectedCallback).toHaveBeenCalled();
        return expect(afterConnectedCallback.calls.count()).toEqual(1);
      });
    });
  });

  return describe('MockPhone#targetOrigin', function() {
    describe('of parent endpoint', () => it('should return origin of an iframe', function() {
      expect(this.parentEndpoint.targetOrigin()).toEqual(''); // no src defined for the default iframe

      const iframeEl = $('<iframe src="http://test.com/path/foo">').appendTo('body');
      const parentEndpoint = new iframePhone.ParentEndpoint(iframeEl[0]);
      return expect(parentEndpoint.targetOrigin()).toEqual('http://test.com');
    }));

    describe('of iframe endpoint', () => it('should return origin of the parent window', function() {
      return expect(this.iframeEndpoint.targetOrigin()).toEqual(window.parent.location.origin);
    }));

    return describe('when origin is specified explicitly', () => it('should be returned', function() {
      const iframeEl = $('<iframe>').appendTo('body');
      const parentEndpoint = new iframePhone.ParentEndpoint(iframeEl[0], 'some.origin.com');
      return expect(parentEndpoint.targetOrigin()).toEqual('some.origin.com');
    }));
  });
}));
*/
