import { mockIFramePhone, MockPhone } from "../interactive-api/mock-iframe-phone";
import * as iframePhone from "iframe-phone";
import * as api from "./api";
import { getClient } from "./client";
import { IGetFirebaseJwtOptions, IGetFirebaseJwtResponse } from "./types";

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
  });

  it("supports setInteractiveState and getInteractiveState", () => {
    api.setInteractiveState({foo: true});
    expect(mockedPhone.messages).toEqual([{type: "interactiveState", content: {foo: true}}]);
    expect(api.getInteractiveState()).toEqual({foo: true});
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
    expect(mockedPhone.messages).toEqual([{type: "hint", content: "test hint"}]);
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

  it("supports getFirebaseJWT called multiple times", () => {
    const requestContent: IGetFirebaseJwtOptions[] = [
      { firebase_app: "foo" },
      { firebase_app: "bar" },
      { firebase_app: "baz" }
    ];
    testRequestResponse({
      method: api.getFirebaseJWT,
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
    const promise = api.getFirebaseJWT({firebase_app: "foo"});
    const content: IGetFirebaseJwtResponse = {
      requestId: 1,
      response_type: "ERROR",
      message: "it's broke!"
    };
    mockedPhone.fakeServerMessage({type: "firebaseJWT", content});
    expect(promise).rejects.toEqual("it's broke!");
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

  it("does not yet implement setAuthoringMetadata", () => {
    expect(() => api.setAuthoringMetadata({
      type: "interactive",
      secondaryTypeForNow: "foo",
      isRequired: true,
      prompt: "bar"
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement setRuntimeMetadata", () => {
    expect(() => api.setRuntimeMetadata({
      type: "interactive",
      isSubmitted: true,
      answerText: "foo"
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement setAuthoringCustomReportFields", () => {
    expect(() => api.setAuthoringCustomReportFields({
      fields: [
        {id: "foo", columnHeading: "Foo"}
      ]
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement setRuntimeCustomReportValues", () => {
    expect(() => api.setRuntimeCustomReportValues({
      values: {foo: "bar"}
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement showModal", () => {
    expect(() => api.showModal({
      uuid: "foo",
      type: "alert",
      style: "info",
      headerText: "Did you know?",
      text: "That is is an alert"
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement closeModal", () => {
    expect(() => api.closeModal({
      uuid: "foo"
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement getInteractiveList", () => {
    expect(() => api.getInteractiveList({
      requestId: 1,
      supportsSnapshots: true
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement setLinkedInteractives", () => {
    expect(() => api.setLinkedInteractives({
      linkedInteractives: []
    })).toThrow(/not yet implemented/);
  });

  it("does not yet implement getInteractiveSnapshot", () => {
    expect(() => api.getInteractiveSnapshot({
      requestId: 1,
      interactiveRuntimeId: "foo"
    })).toThrow(/not yet implemented/);
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
  const mockedMessages: any[] = [];

  options.requestContent.forEach((rc, index) => {
    const requestId = index + 1;
    requestIds.push(requestId);
    const content = {requestId, ...options.requestContent[index]};
    mockedMessages.push({type: options.requestType, content});
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
