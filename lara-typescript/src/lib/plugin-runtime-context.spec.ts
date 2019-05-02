import { generatePluginRuntimeContext } from "./plugin-runtime-context";
import { IClassInfo } from "../plugin-api";
import * as fetch from "jest-fetch-mock";
import * as $ from "jquery";
(window as any).fetch = fetch;

describe("Plugin runtime context helper", () => {
  beforeEach(() => {
    fetch.resetMocks();
  });

  const pluginContext = {
    name: "test",
    url: "http://plugin.url",
    pluginId: 123,
    authoredState: "{authoredState: 123}",
    learnerState: "{learnerState: 321}",
    learnerStateSaveUrl: "http://state.save.url",
    container: document.createElement("div"),
    runId: 100,
    remoteEndpoint: "http://remote.portal.endpoint",
    userEmail: "user@email.com",
    classInfoUrl: "http://portal.class.info.url",
    firebaseJwtUrl: "http://firebase.jwt._FIREBASE_APP_.com",
    wrappedEmbeddable: null
  };

  it("should copy basic properties to runtime context", () => {
    const runtimeContext = generatePluginRuntimeContext(pluginContext);
    expect(runtimeContext.name).toEqual(pluginContext.name);
    expect(runtimeContext.url).toEqual(pluginContext.url);
    expect(runtimeContext.pluginId).toEqual(pluginContext.pluginId);
    expect(runtimeContext.authoredState).toEqual(pluginContext.authoredState);
    expect(runtimeContext.learnerState).toEqual(pluginContext.learnerState);
    expect(runtimeContext.container).toEqual(pluginContext.container);
    expect(runtimeContext.runId).toEqual(pluginContext.runId);
    expect(runtimeContext.remoteEndpoint).toEqual(pluginContext.remoteEndpoint);
    expect(runtimeContext.userEmail).toEqual(pluginContext.userEmail);
  });

  describe("#saveLearnerPluginState", () => {
    const runtimeContext = generatePluginRuntimeContext(pluginContext);
    const state = '{"new": "state"}';
    let ajax = jest.fn();
    beforeEach(() => {
      ajax = jest.fn((opts) => {
        opts.success(state);
      });
      jest.spyOn($, "ajax").mockImplementation(ajax);
    });

    describe("when save succeeds", () => {
      it("should save data", () => {
        expect.assertions(1);
        return runtimeContext.saveLearnerPluginState(state)
          .then((d) => expect(d).toEqual(state));
      });
    });

    describe("when save fails", () => {
      beforeEach(() => {
        ajax = jest.fn((opts) => {
          opts.error("jqXHR", "error", "boom");
        });
        jest.spyOn($, "ajax").mockImplementation(ajax);
      });
      it("should save data", () => {
        expect.assertions(1);
        return runtimeContext.saveLearnerPluginState(state)
          .catch((e) => expect(e).toEqual("boom"));
      });
    });
  });

  describe("#getClassInfo", () => {
    it("returns null when classInfoUrl is not available", () => {
      const runtimeContext = generatePluginRuntimeContext(Object.assign({}, pluginContext, {classInfoUrl: null}));
      const resp = runtimeContext.getClassInfo();
      expect(resp).toBeNull();
    });

    it("provides class information when classInfoUrl is available", done => {
      const runtimeContext = generatePluginRuntimeContext(pluginContext);
      const classInfo: IClassInfo = {id: 123} as IClassInfo;
      fetch.mockResponse(JSON.stringify(classInfo));
      const resp = runtimeContext.getClassInfo();
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.classInfoUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual(classInfo);
        done();
      });
    });

    it("returns error when LARA response is malformed", done => {
      const runtimeContext = generatePluginRuntimeContext(pluginContext);
      fetch.mockResponse("{malformedJSON:");
      const resp = runtimeContext.getClassInfo();
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.classInfoUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.catch(err => {
        done();
      });
    });
  });

  describe("#getFirebaseJwt", () => {
    it("provides token when LARA response is valid", done => {
      const runtimeContext = generatePluginRuntimeContext(pluginContext);
      const jwtResp = { token: `jwtToken.${btoa(JSON.stringify({claimsJson: true}))}`};
      fetch.mockResponse(JSON.stringify(jwtResp));
      const resp = runtimeContext.getFirebaseJwt("testAppName");
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.firebaseJwtUrl.replace("_FIREBASE_APP_", "testAppName"));
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(data).toEqual({
          token: jwtResp.token,
          claims: {claimsJson: true}
        });
        done();
      });
    });

    it("returns error when LARA response is malformed", done => {
      const runtimeContext = generatePluginRuntimeContext(pluginContext);
      const jwtResp = { token: `bad.jwtToken`};
      fetch.mockResponse(JSON.stringify(jwtResp));
      const resp = runtimeContext.getFirebaseJwt("testAppName");
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.firebaseJwtUrl.replace("_FIREBASE_APP_", "testAppName"));
      expect(resp).toBeInstanceOf(Promise);
      resp!.catch(err => {
        expect(err.message).toEqual("Unable to parse JWT Token");
        done();
      });
    });
  });

  describe("#wrappedEmbeddable", () => {
    it("is null when context is not provided", () => {
      const runtimeContext = generatePluginRuntimeContext(pluginContext);
      expect(runtimeContext.wrappedEmbeddable).toBeNull();
    });

    it("is IEmbeddableRuntimeContext instance when initial context is provided", () => {
      const wrappedEmbeddable = {
        container: document.createElement("div"),
        laraJson: {
          name: "Test Interactive",
          type: "MwInteractive",
          ref_id: "86-MwInteractive"
        },
        interactiveStateUrl: "http://interactive.state.url",
        clickToPlayId: "#clickToPlayId"
      };
      const runtimeContext = generatePluginRuntimeContext(Object.assign({}, pluginContext, { wrappedEmbeddable }));
      expect(runtimeContext.wrappedEmbeddable).not.toBeNull();
    });
  });
});
