import React from "react";
import { act, renderHook } from "@testing-library/react-hooks";
import { mockIFramePhone, MockPhone } from "../interactive-api-parent/mock-iframe-phone";
import * as hooks from "./hooks";
import * as iframePhone from "iframe-phone";
import { getClient } from "./client";

jest.mock("./in-frame", () => ({
  inIframe: () => true
}));

jest.mock("iframe-phone", () => {
  return mockIFramePhone();
});

const mockedPhone = iframePhone.getIFrameEndpoint() as unknown as MockPhone;

beforeEach(() => {
  mockedPhone.reset();
});

describe("useInitMessage", () => {
  it("returns initial message from LARA/parent", async () => {
    const { result, waitForNextUpdate } = renderHook(() => hooks.useInitMessage());

    setTimeout(() => {
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: { mode: "runtime", interactiveState: {foo: "bar"}}
      });
    }, 10);

    await waitForNextUpdate();
    expect(result.current).toEqual({
      mode: "runtime",
      interactiveState: {foo: "bar"}
    });
  });
});

describe("useInteractiveState", () => {
  it("returns current interactive state", async () => {
    const { result, waitForNextUpdate } = renderHook(() => hooks.useInteractiveState<any>());

    expect(result.current.interactiveState).toEqual(null);

    setTimeout(() => {
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: { mode: "runtime", interactiveState: {foo: "bar"}}
      });
    }, 10);

    await waitForNextUpdate();
    expect(result.current.interactiveState).toEqual({foo: "bar"});

    act(() => {
      getClient().managedState.interactiveState = {newState: true};
    });

    expect(result.current.interactiveState).toEqual({newState: true});
  });

  it("lets client app update interactive state", async () => {
    const { result } = renderHook(() => hooks.useInteractiveState<any>());

    expect(result.current.interactiveState).toEqual(null);

    act(() => {
      result.current.setInteractiveState({ a: 1 });
    });

    expect(result.current.interactiveState).toEqual({a: 1});
    expect(getClient().managedState.interactiveState).toEqual({a: 1});

    act(() => {
      // Note that `b` property will be lost! State updates are asynchronous, so they might overwrite each other.
      // This is normal, as that's how React's useState works too. Check lines below how to do such update correctly.
      result.current.setInteractiveState({...result.current.interactiveState, b: 2 });
      result.current.setInteractiveState({...result.current.interactiveState, c: 3 });
    });

    expect(result.current.interactiveState).toEqual({a: 1, c: 3});
    expect(getClient().managedState.interactiveState).toEqual({a: 1, c: 3});

    act(() => {
      // If state is updated incrementally, functional update should be used. No property will be lost here.
      result.current.setInteractiveState((prevState: any) => ({...prevState, d: 4 }));
      result.current.setInteractiveState((prevState: any) => ({...prevState, e: 5 }));
    });

    expect(result.current.interactiveState).toEqual({a: 1, c: 3, d: 4, e: 5});
    expect(getClient().managedState.interactiveState).toEqual({a: 1, c: 3, d: 4, e: 5});
  });
});

describe("useAuthoredState", () => {
  it("returns current authored state", async () => {
    const { result, waitForNextUpdate } = renderHook(() => hooks.useAuthoredState<any>());

    expect(result.current.authoredState).toEqual(null);

    setTimeout(() => {
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: { mode: "authoring", authoredState: {foo: "bar"}}
      });
    }, 10);

    await waitForNextUpdate();
    expect(result.current.authoredState).toEqual({foo: "bar"});

    act(() => {
      getClient().managedState.authoredState = {newState: true};
    });

    expect(result.current.authoredState).toEqual({newState: true});
  });

  it("lets client app update interactive state", async () => {
    const { result } = renderHook(() => hooks.useAuthoredState<any>());

    expect(result.current.authoredState).toEqual(null);

    act(() => {
      result.current.setAuthoredState({ a: 1 });
    });

    expect(result.current.authoredState).toEqual({a: 1});
    expect(getClient().managedState.authoredState).toEqual({a: 1});

    act(() => {
      // Note that `b` property will be lost! State updates are asynchronous, so they might overwrite each other.
      // This is normal, as that's how React's useState works too. Check lines below how to do such update correctly.
      result.current.setAuthoredState({...result.current.authoredState, b: 2 });
      result.current.setAuthoredState({...result.current.authoredState, c: 3 });
    });

    expect(result.current.authoredState).toEqual({a: 1, c: 3});
    expect(getClient().managedState.authoredState).toEqual({a: 1, c: 3});

    act(() => {
      // If state is updated incrementally, functional update should be used. No property will be lost here.
      result.current.setAuthoredState((prevState: any) => ({...prevState, d: 4 }));
      result.current.setAuthoredState((prevState: any) => ({...prevState, e: 5 }));
    });

    expect(result.current.authoredState).toEqual({a: 1, c: 3, d: 4, e: 5});
    expect(getClient().managedState.authoredState).toEqual({a: 1, c: 3, d: 4, e: 5});
  });
});

describe("useGlobalInteractiveState", () => {
  it("returns current global interactive state", async () => {
    const { result, waitForNextUpdate } = renderHook(() => hooks.useGlobalInteractiveState<any>());

    expect(result.current.globalInteractiveState).toEqual(null);

    setTimeout(() => {
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: { mode: "runtime", globalInteractiveState: {foo: "bar"}}
      });
    }, 10);

    await waitForNextUpdate();
    expect(result.current.globalInteractiveState).toEqual({foo: "bar"});

    act(() => {
      getClient().managedState.globalInteractiveState = {newState: true};
    });

    expect(result.current.globalInteractiveState).toEqual({newState: true});
  });

  it("lets client app update interactive state", async () => {
    const { result } = renderHook(() => hooks.useGlobalInteractiveState<any>());

    expect(result.current.globalInteractiveState).toEqual(null);

    act(() => {
      result.current.setGlobalInteractiveState({ a: 1 });
    });

    expect(result.current.globalInteractiveState).toEqual({a: 1});
    expect(getClient().managedState.globalInteractiveState).toEqual({a: 1});

    act(() => {
      // Note that `b` property will be lost! State updates are asynchronous, so they might overwrite each other.
      // This is normal, as that's how React's useState works too. Check lines below how to do such update correctly.
      result.current.setGlobalInteractiveState({...result.current.globalInteractiveState, b: 2 });
      result.current.setGlobalInteractiveState({...result.current.globalInteractiveState, c: 3 });
    });

    expect(result.current.globalInteractiveState).toEqual({a: 1, c: 3});
    expect(getClient().managedState.globalInteractiveState).toEqual({a: 1, c: 3});

    act(() => {
      // If state is updated incrementally, functional update should be used. No property will be lost here.
      result.current.setGlobalInteractiveState((prevState: any) => ({...prevState, d: 4 }));
      result.current.setGlobalInteractiveState((prevState: any) => ({...prevState, e: 5 }));
    });

    expect(result.current.globalInteractiveState).toEqual({a: 1, c: 3, d: 4, e: 5});
    expect(getClient().managedState.globalInteractiveState).toEqual({a: 1, c: 3, d: 4, e: 5});
  });
});
