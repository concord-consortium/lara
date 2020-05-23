import { mockIFramePhone, MockPhone } from "../interactive-api/mock-iframe-phone";
import { ISupportedFeatures, IGetFirebaseJwtResponse, IGetFirebaseJwtOptions } from "./types";
import { Client } from "./client";
import { setInIframe } from "./in-frame";

let parentEl: HTMLIFrameElement;
jest.mock("iframe-phone", () => {
  parentEl = document.createElement("iframe");
  return mockIFramePhone(parentEl);
});

interface InteractiveState {
  foo: boolean;
}

interface AuthoredState {
  bar: boolean;
}

interface GlobalInteractiveState {
  baz: boolean;
}

const supportedFeatures: ISupportedFeatures = {
  interactiveState: true,
  authoredState: true,
  aspectRatio: 1
};

let client: Client<InteractiveState, AuthoredState, GlobalInteractiveState>;

const mockedPhone = () => client.iframePhone as unknown as MockPhone;

describe("Client", () => {
  afterEach(() => {
    const mockPhone = client.iframePhone as unknown as MockPhone;
    if (mockedPhone()) {
      mockedPhone().reset();
    }
  });

  describe("outside of an iframe", () => {
    beforeEach(() => {
      setInIframe(false);
      client = new Client<InteractiveState, AuthoredState, GlobalInteractiveState>({
        supportedFeatures
      });
    });

    it("reports it is inside of an iframe", () => {
      expect(client.InIFrame).toBe(false);
    });

    it("does not auto connect", () => {
      expect(mockedPhone()).toBeUndefined();
    });

    it("returns false/reject on all methods", () => {
      expect(client.connect()).toBe(false);
      expect(mockedPhone()).toBeUndefined();
      expect(client.disconnect()).toBe(false);
      expect(client.setInteractiveState({foo: true})).toBe(false);
      expect(client.setHeight(100)).toBe(false);
      expect(client.setSupportedFeatures({})).toBe(false);
      expect(client.setNavigation({})).toBe(false);
      expect(client.setAuthoredState({bar: true})).toBe(false);
      expect(client.setGlobalInteractiveState({baz: true})).toBe(false);
      expect(client.getAuthInfo()).rejects.toEqual("Not in iframe");
      expect(client.getFirebaseJWT({})).rejects.toEqual("Not in iframe");
    });

  });

  describe("inside of an iframe", () => {
    beforeEach(() => {
      setInIframe(true);
    });

    describe("starting disconnected", () => {
      beforeEach(() => {
        client = new Client<InteractiveState, AuthoredState, GlobalInteractiveState>({
          startDisconnected: true,
          supportedFeatures
        });
      });

      it("reports it is inside of an iframe", () => {
        expect(client.InIFrame).toBe(true);
      });

      it("does not auto connect", () => {
        expect(mockedPhone()).toBeUndefined();
      });

      it("can manually connect and disconnect", () => {
        expect(client.connect()).toBe(true);
        expect(mockedPhone()).toBeDefined();
        expect(mockedPhone().numListeners).toBe(4);
        expect(mockedPhone().listenerMessages).toEqual([
          "hello", "getInteractiveState", "initInteractive", "loadInteractiveGlobal"
        ]);

        expect(client.disconnect()).toBe(true);
        expect(mockedPhone()).toBeUndefined();
      });
    });

    describe("starting normally", () => {
      beforeEach(() => {
        client = new Client<InteractiveState, AuthoredState, GlobalInteractiveState>({
          supportedFeatures
        });
      });

      it("auto connects and manually disconnects", () => {
        expect(mockedPhone()).toBeDefined();
        expect(client.disconnect()).toBe(true);
        expect(mockedPhone()).toBeUndefined();
      });
    });

    describe("with callbacks", () => {
      let onHello: jest.Mock<any>;
      let onInitInteractive: jest.Mock<any>;
      let onGetInteractiveState: jest.Mock<any>;
      let onGlobalInteractiveStateUpdated: jest.Mock<any>;

      beforeEach(() => {
        onHello = jest.fn();
        onInitInteractive = jest.fn();
        onGetInteractiveState = jest.fn();
        onGlobalInteractiveStateUpdated = jest.fn();

        client = new Client<InteractiveState, AuthoredState, GlobalInteractiveState>({
          supportedFeatures,
          onHello,
          onInitInteractive,
          onGetInteractiveState,
          onGlobalInteractiveStateUpdated
        });
      });

      it("supports the onHello callback", () => {
        expect(onHello).not.toHaveBeenCalled();
        mockedPhone().fakeServerMessage({type: "hello"});
        expect(onHello).toHaveBeenCalledWith(); // no parameters

        // hello message automatically sends supported features
        expect(mockedPhone().messages).toEqual([{type: "supportedFeatures", content: {
          apiVersion: 1,
          features: { interactiveState: true, authoredState: true, aspectRatio: 1 }
        }}]);
      });

      it("supports the onGetInteractiveState callback", () => {
        expect(onGetInteractiveState).not.toHaveBeenCalled();
        mockedPhone().fakeServerMessage({type: "getInteractiveState"});
        expect(onGetInteractiveState).toHaveBeenCalledWith(); // no parameters
      });

      it("supports the onGlobalInteractiveStateUpdated callback", () => {
        expect(onGlobalInteractiveStateUpdated).not.toHaveBeenCalled();
        mockedPhone().fakeServerMessage({type: "loadInteractiveGlobal", content: {test: true}});
        expect(onGlobalInteractiveStateUpdated).toHaveBeenCalledWith({test: true});
      });

      it("supports the onInitInteractive callback", () => {
        expect(onInitInteractive).not.toHaveBeenCalled();
        mockedPhone().fakeServerMessage({type: "initInteractive", content: {test: true}});
        expect(onInitInteractive).toHaveBeenCalledWith({test: true});
      });

      it("supports setInteractiveState", () => {
        expect(client.setInteractiveState({foo: true})).toBe(true);
        expect(mockedPhone().messages).toEqual([{type: "interactiveState", content: {foo: true}}]);
      });

      it("supports setAuthoredState", () => {
        expect(client.setAuthoredState({bar: true})).toBe(true);
        expect(mockedPhone().messages).toEqual([{type: "authoredState", content: {bar: true}}]);
      });

      it("supports setGlobalInteractiveState", () => {
        expect(client.setGlobalInteractiveState({baz: true})).toBe(true);
        expect(mockedPhone().messages).toEqual([{type: "interactiveStateGlobal", content: {baz: true}}]);
      });

      it("supports setHeight", () => {
        expect(client.setHeight(100)).toBe(true);
        expect(mockedPhone().messages).toEqual([{type: "height", content: 100}]);
      });

      it("supports setSupportedFeatures", () => {
        expect(client.setSupportedFeatures({interactiveState: true, authoredState: true, aspectRatio: 1})).toBe(true);
        expect(mockedPhone().messages).toEqual([{type: "supportedFeatures", content: {
          apiVersion: 1,
          features: { interactiveState: true, authoredState: true, aspectRatio: 1 }
        }}]);
      });

      it("supports setNavigation", () => {
        expect(client.setNavigation({ enableForwardNav: true, message: "foo" })).toBe(true);
        expect(mockedPhone().messages).toEqual([{type: "navigation", content: {
          enableForwardNav: true,
          message: "foo"
        }}]);
      });

      it("supports getAuthInfo called multiple times", () => {
        const requestContent = [
          {},
          {},
          {}
        ];
        testRequestResponse(client, {
          method: client.getAuthInfo,
          requestType: "getAuthInfo",
          requestContent,
          responseType: "authInfo",
          responseContent: [
            {user: "foo"},
            {user: "bar"},
            {user: "baz"}
          ],
          resolvesTo: [
            {user: "foo"},
            {user: "bar"},
            {user: "baz"}
          ]
        });
      });

      it("supports getFirebaseJWT called multiple times", () => {
        const requestContent: IGetFirebaseJwtOptions[] = [
          { firebase_app: "foo" },
          { firebase_app: "bar" },
          { firebase_app: "baz" }
        ];
        testRequestResponse(client, {
          method: client.getFirebaseJWT,
          requestType: "getFirebaseJWT",
          requestContent,
          responseType: "firebaseJWT",
          responseContent: [
            {token: "FOO"},
            {token: "BAR"},
            {token: "BAZ"}
          ],
          resolvesTo: [
            "FOO",
            "BAR",
            "BAZ"
          ]
        });
      });

      it("supports errors from getFirebaseJWT", () => {
        const promise = client.getFirebaseJWT({firebase_app: "foo"});
        const content: IGetFirebaseJwtResponse = {
          requestId: 1,
          response_type: "ERROR",
          message: "it's broke!"
        };
        mockedPhone().fakeServerMessage({type: "firebaseJWT", content});
        expect(promise).rejects.toEqual("it's broke!");
      });

    });

  });

});

// helpers

interface IRequestResponseOptions {
  method: (options: any) => Promise<any>;
  requestType: string;
  requestContent: any[];
  responseType: string;
  responseContent: any[];
  resolvesTo: any[];
}

const testRequestResponse = async (_client: Client, options: IRequestResponseOptions) => {
  const startListeners = mockedPhone().numListeners;
  const requestIds: number[] = [];
  const promises: Array<Promise<any>> = [];
  const mockedMessages: any[] = [];

  options.requestContent.forEach((rc, index) => {
    const requestId = index + 1;
    requestIds.push(requestId);
    const content = {requestId, ...options.requestContent[index]};
    mockedMessages.push({type: options.requestType, content});
    promises.push(options.method.call(_client, options.requestContent[index]));
  });

  // fake out of order responses to ensure requests are routed correctly
  requestIds.sort(() => Math.random() - 0.5);
  // in case you want to see the order...
  // console.log(`${options.responseType} random response order: ${requestIds.join(",")}`);
  requestIds.forEach(requestId => {
    const content = { requestId, ...options.responseContent[requestId - 1] };
    mockedPhone().fakeServerMessage({type: options.responseType, content});
  });

  promises.forEach((promise, index) => {
    expect(promise).resolves.toEqual(options.resolvesTo[index]);
  });

  // it removes the listener
  expect(mockedPhone().numListeners).toEqual(startListeners);
};
