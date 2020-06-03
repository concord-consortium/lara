import { mockIFramePhone, MockPhone } from "../interactive-api-parent/mock-iframe-phone";
import { Client } from "./client";
import * as iframePhone from "iframe-phone";

jest.mock("iframe-phone", () => {
  return mockIFramePhone();
});

let inIframe = false;
jest.mock("./in-frame", () => ({
  inIframe: () => inIframe
}));

const mockedPhone = iframePhone.getIFrameEndpoint() as unknown as MockPhone;

describe("Client", () => {
  afterEach(() => {
    mockedPhone.reset();
  });

  describe("outside of an iframe", () => {
    beforeEach(() => {
      inIframe = false;
    });

    it("throws an error", () => {
      expect(() => {
        const c = new Client();
      }).toThrowError();
    });
  });

  describe("inside of an iframe", () => {
    beforeEach(() => {
      inIframe = true;
    });

    it("throws an error when second Client instance is created", () => {
      expect(() => {
        const c = new Client();
      }).not.toThrowError();
      expect(() => {
        const c = new Client();
      }).toThrowError();
    });

    it("automatically connects to parent window using iframe-phone", () => {
      expect(() => {
        const c = new Client();
      }).not.toThrowError();
      expect(mockedPhone).toBeDefined();
      expect(mockedPhone.listenerMessages).toEqual([
        "initInteractive", "getInteractiveState", "loadInteractiveGlobal"
      ]);
      expect(mockedPhone.initialize).toHaveBeenCalled();
    });

    it("handles init message and saves interactive, authored and global interactive states", () => {
      const client = new Client();
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: {
          mode: "runtime",
          interactiveState: { interactiveState: true },
          authoredState: { authoredState: true },
          globalInteractiveState: { globalState: true }
        }
      });
      expect(client.managedState.interactiveState).toEqual({ interactiveState: true });
      expect(client.managedState.authoredState).toEqual({ authoredState: true });
      expect(client.managedState.globalInteractiveState).toEqual({ globalState: true });
    });

    it("automatically supports the getInteractiveState message", () => {
      const client = new Client();
      client.managedState.interactiveState = {test: 123};
      mockedPhone.fakeServerMessage({type: "getInteractiveState"});
      expect(mockedPhone.messages).toEqual([{type: "interactiveState", content: {test: 123}}]);
    });

    it("automatically supports the loadInteractiveGlobal message", () => {
      const client = new Client();
      client.managedState.interactiveState = {test: 123};
      mockedPhone.fakeServerMessage({type: "loadInteractiveGlobal", content: {test: 123}});
      expect(client.managedState.globalInteractiveState).toEqual({ test: 123 });
    });

    it("lets you add and remove custom message listener", () => {
      const client = new Client();
      const listener = jest.fn();
      client.addListener("authInfo", listener);
      mockedPhone.fakeServerMessage({type: "authInfo", content: {test: 123}});
      expect(listener).toHaveBeenCalledWith({test: 123});
      expect(listener).toHaveBeenCalledTimes(1);

      client.removeListener("authInfo");
      mockedPhone.fakeServerMessage({type: "authInfo", content: {test: 321}});
      expect(listener).toHaveBeenCalledTimes(1);
    });

    it("lets you add custom message listener with requestId", () => {
      const client = new Client();
      const listener = jest.fn();
      const requestId = 123;
      client.addListener("authInfo", listener, requestId);

      // no request ID
      mockedPhone.fakeServerMessage({type: "authInfo", content: {test: 123}});
      expect(listener).toHaveBeenCalledTimes(0);

      // wrong request ID
      mockedPhone.fakeServerMessage({type: "authInfo", content: {test: 123, requestId: 999}});
      expect(listener).toHaveBeenCalledTimes(0);

      // correct request ID
      mockedPhone.fakeServerMessage({type: "authInfo", content: {test: 123, requestId: 123}});
      expect(listener).toHaveBeenCalledTimes(1);
      expect(listener).toHaveBeenCalledWith({test: 123});

      // listener should be removed now
      mockedPhone.fakeServerMessage({type: "authInfo", content: {test: 321}});
      expect(listener).toHaveBeenCalledTimes(1);
    });
  });
});
