import { generateEmbeddableRuntimeContext } from "./embeddable-runtime-context";
import { IInteractiveState } from "../plugin-api";
import { emitInteractiveAvailable, emitInteractiveSupportedFeatures } from "../events";
import * as fetch from "jest-fetch-mock";
import { IEmbeddableContextOptions } from "./plugin-context";
(window as any).fetch = fetch;

describe("Embeddable runtime context helper", () => {
  beforeEach(() => {
    fetch.resetMocks();
  });

  const embeddableContext: IEmbeddableContextOptions = {
    container: document.createElement("div"),
    laraJson: {
      name: "Test Interactive",
      type: "MwInteractive",
      ref_id: "86-MwInteractive"
    },
    interactiveStateUrl: "http://interactive.state.url",
    interactiveAvailable: true
  };

  it("should copy basic properties to runtime context", () => {
    const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
    expect(runtimeContext.container).toEqual(embeddableContext.container);
    expect(runtimeContext.laraJson).toEqual(embeddableContext.laraJson);
  });

  describe("#getInteractiveState", () => {
    it("returns null when interactiveStateUrl is not available", () => {
      const runtimeContext = generateEmbeddableRuntimeContext(
        Object.assign({}, embeddableContext, {interactiveStateUrl: null})
      );
      const resp = runtimeContext.getInteractiveState();
      expect(resp).toBeNull();
    });

    it("provides interactive state when interactiveStateUrl is available", done => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      const interactiveState: IInteractiveState = {id: 123} as IInteractiveState;
      fetch.mockResponse(JSON.stringify(interactiveState));
      const resp = runtimeContext.getInteractiveState();
      expect(fetch.mock.calls[0][0]).toEqual(embeddableContext.interactiveStateUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual(interactiveState);
        done();
      });
    });

    it("returns error when LARA response is malformed", done => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      fetch.mockResponse("{malformedJSON:");
      const resp = runtimeContext.getInteractiveState();
      expect(fetch.mock.calls[0][0]).toEqual(embeddableContext.interactiveStateUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.catch(err => {
        done();
      });
    });
  });

  describe("#getReportingUrl", () => {
    it("returns null when interactiveStateUrl is not available", () => {
      const runtimeContext = generateEmbeddableRuntimeContext(
        Object.assign({}, embeddableContext, {interactiveStateUrl: null})
      );
      const resp = runtimeContext.getReportingUrl();
      expect(resp).toBeNull();
    });

    it("returns null when interactive state doesn't include reporting URL", done => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      fetch.mockResponse(JSON.stringify({raw_data: '{"lara_options": {"prop": "value" }}'} as IInteractiveState));
      const resp = runtimeContext.getReportingUrl();
      expect(fetch.mock.calls[0][0]).toEqual(embeddableContext.interactiveStateUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toBeNull();
        done();
      });
    });

    it("returns reporting URL when it's available", done => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      fetch.mockResponse(JSON.stringify({
        raw_data: '{"lara_options": {"reporting_url": "reporting.url" }}'
      } as IInteractiveState));
      const resp = runtimeContext.getReportingUrl();
      expect(fetch.mock.calls[0][0]).toEqual(embeddableContext.interactiveStateUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual("reporting.url");
        done();
      });
    });

    it("accepts interactiveStatePromise as an optional parameter and performs only one network request", done => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      fetch.mockResponseOnce(JSON.stringify({
        raw_data: '{"lara_options": {"reporting_url": "reporting.url" }}'
      } as IInteractiveState));
      // Note that reporting URL is different here. Test below ensures that only one network request is performed.
      fetch.mockResponseOnce(JSON.stringify({
        raw_data: '{"lara_options": {"reporting_url": "WRONG reporting.url" }}'
      } as IInteractiveState));
      const interactiveStatePromise = runtimeContext.getInteractiveState();
      const resp = runtimeContext.getReportingUrl(interactiveStatePromise!);
      expect(fetch.mock.calls[0][0]).toEqual(embeddableContext.interactiveStateUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual("reporting.url");
        done();
      });
    });
  });

  describe("#onInteractiveAvailable", () => {
    it("accepts handler and calls it when this particular interactive is actually started", () => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      const handler = jest.fn();
      runtimeContext.onInteractiveAvailable(handler);
      // Different container => different interactive. Handler should not be called.
      emitInteractiveAvailable({ container: document.createElement("div"), available: false });
      expect(handler).toHaveBeenCalledTimes(0);
      const event = { container: embeddableContext.container, available: true };
      emitInteractiveAvailable(event);
      expect(handler).toHaveBeenCalledWith(event);
    });
  });

  describe("#onInteractiveSupportedFeatures", () => {
    it("accepts handler and calls it when this particular interactive specifies its supported features", () => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      const handler = jest.fn();
      runtimeContext.onInteractiveSupportedFeatures(handler);
      // Different container => different interactive. Handler should not be called.
      emitInteractiveSupportedFeatures({ container: document.createElement("div"), supportedFeatures: {} });
      expect(handler).toHaveBeenCalledTimes(0);
      const event = { container: embeddableContext.container, supportedFeatures: {} };
      emitInteractiveSupportedFeatures(event);
      expect(handler).toHaveBeenCalledWith(event);
    });
  });

  describe("#sendCustomMessage", () => {
    it("provides sendCustomMessage function", () => {
      const runtimeContext = generateEmbeddableRuntimeContext(embeddableContext);
      runtimeContext.sendCustomMessage({ type: "foo", content: { bar: true } });
    });
  });
});
