import { mockIFramePhone, setAutoConnect, MockPhone } from "./mock-iframe-phone";
import { IframePhoneManager } from "./iframe-phone-manager";

const iframeEl = document.createElement("iframe");

jest.mock("iframe-phone", () => mockIFramePhone(iframeEl));

describe("IframePhoneManager", () => {

  describe("#getInstance", () => {
    it("should return the same instance on multiple calls", () => {
      const instance1 = IframePhoneManager.getInstance();
      const instance2 = IframePhoneManager.getInstance();
      expect(instance1).toBe(instance2);
    });
  });

  describe("#getPhone", () => {
    it("returns the same phone even if called multiple times", () => {
      const phone1 = IframePhoneManager.getPhone(iframeEl);
      const phone2 = IframePhoneManager.getPhone(iframeEl);
      return expect(phone1).toBe(phone2);
    });

    it("executes all provided afterConnectedCallbacks (async!)", (done) => {
      setAutoConnect(false);

      const callback = jest.fn();
      IframePhoneManager.getPhone(iframeEl, callback);
      const phone = IframePhoneManager.getPhone(iframeEl, callback) as unknown as MockPhone;
      expect(callback).not.toHaveBeenCalled();

      setTimeout(() => {
        phone.fakeConnection();
        // Callbacks added before connection was initialized should be executed right away when it happens
        // (in real world it's async).
        expect(callback).toHaveBeenCalled();
        expect(callback).toHaveBeenCalledTimes(2);
        // Callbacks added after connection was initialized should be executed asynchronously in the future
        // (so we're consistent and we always simulate async connection to an iframe).
        callback.mockReset();
        IframePhoneManager.getPhone(iframeEl, callback);
        expect(callback).not.toHaveBeenCalled();
        // Test passes only if done is called within next 5 seconds.
        return IframePhoneManager.getPhone(iframeEl, done);
      }, 1);
    });
  });

  describe("#getRpcEndpoint", () => {
    it("returns the same RPC endpoint even if called multiple times", () => {
      const rpc1 = IframePhoneManager.getRpcEndpoint(iframeEl, "test-namespace");
      const rpc2 = IframePhoneManager.getRpcEndpoint(iframeEl, "test-namespace");
      expect(rpc1).toBe(rpc2);
    });

    it("returns different RPC endpoint for different namespaces", () => {
      const rpc1 = IframePhoneManager.getRpcEndpoint(iframeEl, "test-namespace-1");
      const rpc2 = IframePhoneManager.getRpcEndpoint(iframeEl, "test-namespace-2");
      expect(rpc1).not.toBe(rpc2);
    });
  });
});
