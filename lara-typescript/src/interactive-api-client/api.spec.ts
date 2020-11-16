import { mockIFramePhone, MockPhone } from "../interactive-api-parent/mock-iframe-phone";
import * as iframePhone from "iframe-phone";
import * as api from "./api";
import { getClient } from "./client";
import {
  IGetFirebaseJwtResponse,
  IShowAlert,
  IShowDialog,
  IShowLightbox,
  ICloseModal,
  IGetInteractiveSnapshotOptions
} from "./types";

jest.mock("./in-frame", () => ({
  inIframe: () => true
}));

jest.mock("iframe-phone", () => {
  return mockIFramePhone();
});

const mockedPhone = iframePhone.getIFrameEndpoint() as unknown as MockPhone;

describe("api", () => {
  beforeEach(() => {
    mockedPhone.reset();
  });

  it("supports getInitInteractiveMessage", async () => {
    setTimeout(() => {
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: { mode: "runtime", interactiveState: {foo: "bar"}}
      });
    }, 10);
    expect(await api.getInitInteractiveMessage()).toEqual({
      mode: "runtime",
      interactiveState: {foo: "bar"}
    });
    // interactive state shouldn't be dirty after initial load.
    expect(getClient().managedState.interactiveStateDirty).toEqual(false);
  });

  it("supports setInteractiveState and getInteractiveState", (done) => {
    api.setInteractiveState({foo: true});
    expect(api.getInteractiveState()).toEqual({foo: true});
    expect(getClient().managedState.interactiveStateDirty).toEqual(true);
    setTimeout(() => {
      expect(mockedPhone.messages).toEqual([{type: "interactiveState", content: {foo: true}}]);
      expect(getClient().managedState.interactiveStateDirty).toEqual(false);
      done();
    }, api.setInteractiveStateTimeout + 1);
  });

  it("supports setAuthoredState and getAuthoredState", () => {
    api.setAuthoredState({bar: true});
    expect(mockedPhone.messages).toEqual([{type: "authoredState", content: {bar: true}}]);
    expect(api.getAuthoredState()).toEqual({bar: true});
  });

  it("supports setGlobalInteractiveState", () => {
    api.setGlobalInteractiveState({baz: true});
    expect(mockedPhone.messages).toEqual([{type: "interactiveStateGlobal", content: {baz: true}}]);
    expect(api.getGlobalInteractiveState()).toEqual({baz: true});
  });

  it("supports setHeight", () => {
    api.setHeight(123);
    expect(mockedPhone.messages).toEqual([{type: "height", content: 123}]);
  });

  it("supports setHint", () => {
    api.setHint("test hint");
    expect(mockedPhone.messages).toEqual([{type: "hint", content: {text: "test hint"}}]);
  });

  it("supports log", () => {
    api.log("test action", {param1: 1});
    expect(mockedPhone.messages).toEqual([{type: "log", content: {action: "test action", data: {param1: 1}}}]);
  });

  it("supports [add|remove]CustomMessageListener", () => {
    const handler = jest.fn();
    api.addCustomMessageListener(handler, { handles: { foo: true } });
    api.removeCustomMessageListener();
  });

  it("supports setSupportedFeatures", () => {
    api.setSupportedFeatures({ interactiveState: true, authoredState: true, aspectRatio: 1 });
    expect(mockedPhone.messages).toEqual([{
      type: "supportedFeatures", content: {
        apiVersion: 1,
        features: { interactiveState: true, authoredState: true, aspectRatio: 1 }
      }
    }]);
  });

  it("supports setNavigation", () => {
    api.setNavigation({ enableForwardNav: true, message: "foo" });
    expect(mockedPhone.messages).toEqual([{
      type: "navigation",
      content: {
        enableForwardNav: true,
        message: "foo"
      }
    }]);
  });

  it("supports getAuthInfo called multiple times", async () => {
    const requestContent = [
      {},
      {},
      {}
    ];
    await testRequestResponse({
      method: api.getAuthInfo,
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

  it("supports getFirebaseJwt called multiple times", () => {
    const requestContent: string[] = [
      "foo",
      "bar",
      "baz"
    ];
    testRequestResponse({
      method: api.getFirebaseJwt,
      requestType: "getFirebaseJwt",
      requestContent,
      responseType: "firebaseJWT",
      responseContent: [
        // Tokens generated using: https://jwt.io/
        {token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsicGxhdGZvcm1fdXNlcl9pZCI6MX19.uA1QBaqlcsWv7cGIEn9WvhBT1PZW7l1VD28dz9mu-U8"},
        {token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsicGxhdGZvcm1fdXNlcl9pZCI6Mn19.--dC7AzrLHCGENkoGbwtJvst0OEG2IDZmDZSMZG-6D0"},
        {token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsicGxhdGZvcm1fdXNlcl9pZCI6M319.yxGmCe0ZDavxl1NFrVw9-WDhbDFZ6J5hKdhXDeUPkAQ"}
      ],
      resolvesTo: [
        {claims: { claims: { platform_user_id: 1 } }, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsicGxhdGZvcm1fdXNlcl9pZCI6MX19.uA1QBaqlcsWv7cGIEn9WvhBT1PZW7l1VD28dz9mu-U8"},
        {claims: { claims: { platform_user_id: 2 } }, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsicGxhdGZvcm1fdXNlcl9pZCI6Mn19.--dC7AzrLHCGENkoGbwtJvst0OEG2IDZmDZSMZG-6D0"},
        {claims: { claims: { platform_user_id: 3 } }, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGFpbXMiOnsicGxhdGZvcm1fdXNlcl9pZCI6M319.yxGmCe0ZDavxl1NFrVw9-WDhbDFZ6J5hKdhXDeUPkAQ"},
      ]
    });
  });

  it("supports errors from getFirebaseJwt", () => {
    const promise = api.getFirebaseJwt("foo");
    const content: IGetFirebaseJwtResponse = {
      requestId: 1,
      response_type: "ERROR",
      message: "it's broke!"
    };
    mockedPhone.fakeServerMessage({type: "firebaseJWT", content});
    expect(promise).rejects.toEqual("it's broke!");
  });

  it("handles incorrect JWTs", () => {
    const promise = api.getFirebaseJwt("foo");
    const content: IGetFirebaseJwtResponse = {
      requestId: 1,
      token: "invalid JWT"
    };
    mockedPhone.fakeServerMessage({type: "firebaseJWT", content});
    expect(promise).rejects.toEqual("Unable to parse JWT Token");
  });

  it("supports interactive state observing", () => {
    const listener = jest.fn();
    api.addInteractiveStateListener(listener);
    getClient().managedState.interactiveState = {foo: 123};
    expect(listener).toHaveBeenCalledWith({foo: 123});
    expect(listener).toHaveBeenCalledTimes(1);

    api.removeInteractiveStateListener(listener);
    getClient().managedState.interactiveState = {bar: 123};
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it("supports authored state observing", () => {
    const listener = jest.fn();
    api.addAuthoredStateListener(listener);
    getClient().managedState.authoredState = {foo: 123};
    expect(listener).toHaveBeenCalledWith({foo: 123});
    expect(listener).toHaveBeenCalledTimes(1);

    api.removeAuthoredStateListener(listener);
    getClient().managedState.authoredState = {bar: 123};
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it("supports global interactive state observing", () => {
    const listener = jest.fn();
    api.addGlobalInteractiveStateListener(listener);
    getClient().managedState.globalInteractiveState = {foo: 123};
    expect(listener).toHaveBeenCalledWith({foo: 123});
    expect(listener).toHaveBeenCalledTimes(1);

    api.removeGlobalInteractiveStateListener(listener);
    getClient().managedState.globalInteractiveState = {bar: 123};
    expect(listener).toHaveBeenCalledTimes(1);
  });

  it("should implement showModal [alert]", () => {
    const options: IShowAlert = {
      uuid: "foo",
      type: "alert",
      style: "correct",
      title: "Custom Title",
      text: "Custom message"
    };
    api.showModal(options);
    expect(mockedPhone.messages).toEqual([{ type: "showModal", content: options }]);
  });

  it("should implement showModal [lightbox]", () => {
    const options: IShowLightbox = {
      uuid: "foo",
      type: "lightbox",
      url: "https://concord.org"
    };
    api.showModal(options);
    expect(mockedPhone.messages).toEqual([{ type: "showModal", content: options }]);
  });

  it("should implement getInteractiveList", () => {
    const requestContent = [
      {scope: "page", supportsSnapshots: true}
    ];
    testRequestResponse({
      method: api.getInteractiveList,
      requestType: "getInteractiveList",
      requestContent,
      responseType: "interactiveList",
      responseContent: [
        {interactives: []}
      ],
      resolvesTo: [
        {interactives: []}
      ]
    });
  });

  it("should implement setLinkedInteractives", () => {
    api.setLinkedInteractives({
      linkedInteractives: [
        {id: "interactive_1", label: "one"},
        {id: "interactive_2", label: "two"}
      ],
      linkedState: "interactive_1"
    });
    expect(mockedPhone.messages).toEqual([{type: "setLinkedInteractives", content: {
      linkedInteractives: [
        {id: "interactive_1", label: "one"},
        {id: "interactive_2", label: "two"}
      ],
      linkedState: "interactive_1"
    }}]);
  });

  it("does not yet implement showModal [dialog]", () => {
    const options: IShowDialog = {
      uuid: "foo",
      type: "dialog",
      url: "https://concord.org"
    };
    api.showModal(options);
    expect(mockedPhone.messages).toEqual([{ type: "showModal", content: options }]);
  });

  it("should close a modal alert/lightbox/dialog", () => {
    const options: ICloseModal = { uuid: "foo" };
    api.closeModal(options);
    expect(mockedPhone.messages).toEqual([{ type: "closeModal", content: options }]);
  });

  it("should implement getInteractiveSnapshot", () => {
    const requestContent: IGetInteractiveSnapshotOptions[] = [
      {interactiveItemId: "interactive_123"}
    ];
    testRequestResponse({
      method: api.getInteractiveSnapshot,
      requestType: "getInteractiveSnapshot",
      requestContent,
      responseType: "interactiveSnapshot",
      responseContent: [
        {success: true, snapshotUrl: "http://snapshot.com/123"}
      ],
      resolvesTo: [
        {success: true, snapshotUrl: "http://snapshot.com/123"}
      ]
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

const testRequestResponse = async (options: IRequestResponseOptions) => {
  // call getClient() just before saving phone.numListeners. Client will add some default listeners itself.
  // And it might not be initialized before the first api method is called.
  getClient();
  const startListeners = mockedPhone.numListeners;
  const requestIds: number[] = [];
  const promises: Array<Promise<any>> = [];

  options.requestContent.forEach((rc, index) => {
    const requestId = index + 1;
    requestIds.push(requestId);
    promises.push(options.method(options.requestContent[index]));
  });

  // fake out of order responses to ensure requests are routed correctly
  requestIds.sort(() => Math.random() - 0.5);
  // in case you want to see the order...
  // console.log(`${options.responseType} random response order: ${requestIds.join(",")}`);
  requestIds.forEach(requestId => {
    const content = { requestId, ...options.responseContent[requestId - 1] };
    mockedPhone.fakeServerMessage({type: options.responseType, content});
  });

  promises.forEach((promise, index) => {
    expect(promise).resolves.toEqual(options.resolvesTo[index]);
  });

  // it removes the listener
  expect(mockedPhone.numListeners).toEqual(startListeners);
};
