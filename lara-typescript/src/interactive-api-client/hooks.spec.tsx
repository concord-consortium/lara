import * as React from "react";
import { act, renderHook } from "@testing-library/react-hooks";
import { render } from "@testing-library/react";
import { mockIFramePhone, MockPhone } from "../interactive-api-lara-host/mock-iframe-phone";
import * as hooks from "./hooks";
import * as iframePhone from "iframe-phone";
import { getClient } from "./client";
import { IAccessibilitySettings } from "./types";
import { getFamilyForFontType } from "../shared/accessibility";

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

  it("ensures that interactive state is always observed correctly", async () => {
    const TestComponent: React.FC = () => {
      const { interactiveState } = hooks.useInteractiveState<any>();
      const managedStateUpdated = React.useRef(false);

      if (!managedStateUpdated.current) {
        // Immediate update of interactiveState. In real life it wouldn't be done in the component obviously,
        // but that's an easy way to ensure problematic timing - after initial render of the useInteractiveState hook,
        // but before useEffect defined in useInteractiveState is called. This is regression test related to this issue:
        // https://www.pivotaltracker.com/story/show/174154314
        getClient().managedState.interactiveState = "new state 123";
        // Prevent infinite loop, update authoredState just once.
        managedStateUpdated.current = true;
      }
      return <div>{ interactiveState }</div>;
    };

    const { container } = render(<TestComponent />);
    expect(container.textContent).toEqual("new state 123");
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

  it("lets client app update authored state", async () => {
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

  it("ensures that authored state is always observed correctly", async () => {
    const TestComponent: React.FC = () => {
      const { authoredState } = hooks.useAuthoredState<any>();
      const managedStateUpdated = React.useRef(false);

      if (!managedStateUpdated.current) {
        // Immediate update of authoredState. In real life it wouldn't be done in the component obviously,
        // but that's an easy way to ensure problematic timing - after initial render of the useAuthoredState hook,
        // but before useEffect defined in useAuthoredState is called. This is regression test related to this issue:
        // https://www.pivotaltracker.com/story/show/174154314
        getClient().managedState.authoredState = "new state 123";
        // Prevent infinite loop, update authoredState just once.
        managedStateUpdated.current = true;
      }
      return <div>{ authoredState }</div>;
    };

    const { container } = render(<TestComponent />);
    expect(container.textContent).toEqual("new state 123");
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

  it("ensures that global interactive state is always observed correctly", async () => {
    const TestComponent: React.FC = () => {
      const { globalInteractiveState } = hooks.useGlobalInteractiveState<any>();
      const managedStateUpdated = React.useRef(false);

      if (!managedStateUpdated.current) {
        // Immediate update of globalInteractiveState. In real life it wouldn't be done in the component obviously,
        // but that's an easy way to ensure problematic timing - after initial render of the useGlobalInteractiveState
        // hook, but before useEffect defined in useGlobalInteractiveState is called. This is regression test related
        // to this issue: https://www.pivotaltracker.com/story/show/174154314
        getClient().managedState.globalInteractiveState = "new state 123";
        // Prevent infinite loop, update authoredState just once.
        managedStateUpdated.current = true;
      }
      return <div>{ globalInteractiveState }</div>;
    };

    const { container } = render(<TestComponent />);
    expect(container.textContent).toEqual("new state 123");
  });
});

describe("useCustomMessages", () => {

  it("does something", () => {
    const handler = jest.fn();
    renderHook(() => hooks.useCustomMessages(handler, { foo: true }));
    getClient().setSupportedFeatures({ apiVersion: 1, features: {} });
  });

});

describe("useReportItem", () => {
  it("lets client set answer handler and metadata", async () => {
    const handler = jest.fn();
    const metadata: any = { foo: 1 };

    renderHook(() => hooks.useReportItem<any, any>({ handler, metadata }));

    expect(mockedPhone.messages[0]).toEqual({ type: "reportItemClientReady", content: metadata });

    const request = { bar: 1 };
    mockedPhone.fakeServerMessage({
      type: "getReportItemAnswer",
      content: request
    });
    expect(handler).toHaveBeenCalledWith(request);
  });
});

describe("useAccessibility", () => {
  it("returns the accessibility settings from the initMessage", async () => {
    const accessibility: IAccessibilitySettings = {
      fontSize: "large",
      fontSizeInPx: 22,
      fontType: "notebook",
      fontFamilyForType: "test-font-family, fallback-font-family"
    };

    const { waitForNextUpdate } = renderHook(() => hooks.useInitMessage());
    const { result } = renderHook(() => hooks.useAccessibility({
      updateDOM: {
        enabled: true,
        fontFamilySelector: "body",
      },
    }));

    setTimeout(() => {
      mockedPhone.fakeServerMessage({
        type: "initInteractive",
        content: { mode: "runtime", accessibility }
      });
    }, 10);

    // the DOM should not have font updates yet
    const beforeHtml = document.getElementsByTagName("html").item(0);
    const beforeBody = document.getElementsByTagName("body").item(0);
    const beforeStyle = document.getElementsByTagName("style").item(0);
    expect(beforeHtml?.style.getPropertyValue("font-size")).toEqual("");
    expect(beforeStyle).toEqual(null);
    expect(beforeBody?.classList.toString()).toBe("");

    await waitForNextUpdate();
    expect(result.current).toEqual(accessibility);

    // the DOM should now have font updates
    const afterHtml = document.getElementsByTagName("html").item(0);
    const afterBody = document.getElementsByTagName("body").item(0);
    const afterStyle = document.getElementsByTagName("style").item(0);
    expect(afterHtml?.style.getPropertyValue("font-size")).toEqual("22px");
    expect((afterStyle?.sheet?.cssRules[0] as any).selectorText).toEqual("body");
    expect((afterStyle?.sheet?.cssRules[0] as any).style["font-family"]).toEqual("test-font-family, fallback-font-family");
    expect(afterBody?.classList.toString()).toBe("font-size-large font-type-notebook");
  });
});
