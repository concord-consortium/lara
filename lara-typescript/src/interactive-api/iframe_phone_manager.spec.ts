describe("IframePhoneManager", () => {
  it("TODO", () => {
    expect(true).toBe(true);
  });
});

/*
describe('IframePhoneManager', function() {
  beforeEach(function() {
    setFixtures('<iframe src="http://test.com"></iframe>');
    return this.iframeEl = $('iframe')[0];});

  it('is available in global namespace', () => expect(IframePhoneManager).toEqual(jasmine.anything()));

  return describe('#getPhone', function() {
    it('returns the same phone even if called multiple times', function() {
      const phone1 = IframePhoneManager.getPhone(this.iframeEl);
      const phone2 = IframePhoneManager.getPhone(this.iframeEl);
      return expect(phone1).toBe(phone2);
    });

    it('executes all provided afterConnectedCallbacks (async!)', function(done) {
      return jasmine.mockIframePhone.withMock(() => {
        jasmine.mockIframePhone.autoConnect = false;

        const callback = jasmine.createSpy('callback');
        IframePhoneManager.getPhone(this.iframeEl, callback);
        const phone = IframePhoneManager.getPhone(this.iframeEl, callback);
        expect(callback).not.toHaveBeenCalled();
        return setTimeout(() => {
          phone.fakeConnection();
          // Callbacks added before connection was initialized should be executed right away when it happens
          // (in real world it's async).
          expect(callback).toHaveBeenCalled();
          expect(callback.calls.count()).toEqual(2);
          // Callbacks added after connection was initialized should be executed asynchronously in the future
          // (so we're consistent and we always simulate async connection to an iframe).
          callback.calls.reset();
          IframePhoneManager.getPhone(this.iframeEl, callback);
          expect(callback).not.toHaveBeenCalled();
          // Test passes only if done is called within next 5 seconds.
          return IframePhoneManager.getPhone(this.iframeEl, done);
        }
        , 1);
      });
    });

    return describe('#getRpcEndpoint', function() {
      it('returns the same RPC endpoint even if called multiple times', function() {
        const rpc1 = IframePhoneManager.getRpcEndpoint(this.iframeEl, 'test-namespace');
        const rpc2 = IframePhoneManager.getRpcEndpoint(this.iframeEl, 'test-namespace');
        return expect(rpc1).toBe(rpc2);
      });

      return it('returns different RPC endpoint for different namespaces', function() {
        const rpc1 = IframePhoneManager.getRpcEndpoint(this.iframeEl, 'test-namespace-1');
        const rpc2 = IframePhoneManager.getRpcEndpoint(this.iframeEl, 'test-namespace-2');
        return expect(rpc1).not.toBe(rpc2);
      });
    });
  });
});
*/
