import { generateRuntimePluginContext,
         IEmbeddableContextOptions,
         IPluginRuntimeContextOptions,
         IPluginAuthoringContextOptions,
         generateAuthoringPluginContext} from "./plugin-context";
import { IClassInfo } from "../plugin-api";
import * as fetch from "jest-fetch-mock";
import * as $ from "jquery";
(window as any).fetch = fetch;

describe("Plugin runtime context helper", () => {
  beforeEach(() => {
    fetch.resetMocks();
  });

  const pluginContext: IPluginRuntimeContextOptions = {
    type: "runtime",
    name: "test",
    url: "http://plugin.url",
    pluginId: 123,
    embeddablePluginId: 42,
    authoredState: "{authoredState: 123}",
    learnerState: "{learnerState: 321}",
    learnerStateSaveUrl: "http://state.save.url",
    container: document.createElement("div"),
    runId: 100,
    remoteEndpoint: "http://remote.portal.endpoint",
    userEmail: "user@email.com",
    classInfoUrl: "http://portal.class.info.url",
    firebaseJwtUrl: "http://firebase.jwt._FIREBASE_APP_.com",
    portalJwtUrl: "http://portal.jwt._FIREBASE_APP_.com",
    wrappedEmbeddable: null,
    componentLabel: "test",
    resourceUrl: "http://lara.activity.com/123",
    offlineMode: false
  };

  it("should copy basic properties to runtime context", () => {
    const runtimeContext = generateRuntimePluginContext(pluginContext);
    expect(runtimeContext.name).toEqual(pluginContext.name);
    expect(runtimeContext.url).toEqual(pluginContext.url);
    expect(runtimeContext.pluginId).toEqual(pluginContext.pluginId);
    expect(runtimeContext.authoredState).toEqual(pluginContext.authoredState);
    expect(runtimeContext.learnerState).toEqual(pluginContext.learnerState);
    expect(runtimeContext.container).toEqual(pluginContext.container);
    expect(runtimeContext.runId).toEqual(pluginContext.runId);
    expect(runtimeContext.remoteEndpoint).toEqual(pluginContext.remoteEndpoint);
    expect(runtimeContext.userEmail).toEqual(pluginContext.userEmail);
    expect(runtimeContext.resourceUrl).toEqual(pluginContext.resourceUrl);
  });

  describe("#saveLearnerPluginState", () => {
    const runtimeContext = generateRuntimePluginContext(pluginContext);
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
      const runtimeContext = generateRuntimePluginContext(Object.assign({}, pluginContext, {classInfoUrl: null}));
      const resp = runtimeContext.getClassInfo();
      expect(resp).toBeNull();
    });

    it("provides class information when classInfoUrl is available", done => {
      const runtimeContext = generateRuntimePluginContext(pluginContext);
      const jwtResp = { token: `jwtToken.${btoa(JSON.stringify({claimsJson: true}))}`};
      const classInfo: IClassInfo = {id: 123} as IClassInfo;
      fetch.mockResponses([JSON.stringify(jwtResp)], [JSON.stringify(classInfo)]);
      const resp = runtimeContext.getClassInfo();
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.portalJwtUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.then(data => {
        expect(fetch.mock.calls[1][0]).toEqual(pluginContext.classInfoUrl);
        expect(data).toEqual(classInfo);
        done();
      });
    });

    it("returns error when LARA response is malformed", done => {
      const runtimeContext = generateRuntimePluginContext(pluginContext);
      const jwtResp = { token: `jwtToken.${btoa(JSON.stringify({claimsJson: true}))}`};
      fetch.mockResponses([JSON.stringify(jwtResp)], ["{malformedJSON:"]);
      const resp = runtimeContext.getClassInfo();
      expect(fetch.mock.calls[0][0]).toEqual(pluginContext.portalJwtUrl);
      expect(resp).toBeInstanceOf(Promise);
      resp!.catch(err => {
        expect(fetch.mock.calls[1][0]).toEqual(pluginContext.classInfoUrl);
        done();
      });
    });
  });

  describe("#getFirebaseJwt", () => {
    it("provides token when LARA response is valid", done => {
      const runtimeContext = generateRuntimePluginContext(pluginContext);
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
      const runtimeContext = generateRuntimePluginContext(pluginContext);
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
      const runtimeContext = generateRuntimePluginContext(pluginContext);
      expect(runtimeContext.wrappedEmbeddable).toBeNull();
    });

    it("is IEmbeddableRuntimeContext instance when initial context is provided", () => {
      const wrappedEmbeddable: IEmbeddableContextOptions = {
        container: document.createElement("div"),
        laraJson: {
          name: "Test Interactive",
          type: "MwInteractive",
          ref_id: "86-MwInteractive"
        },
        interactiveStateUrl: "http://interactive.state.url",
        interactiveAvailable: true
      };
      const runtimeContext = generateRuntimePluginContext(Object.assign({}, pluginContext, { wrappedEmbeddable }));
      expect(runtimeContext.wrappedEmbeddable).not.toBeNull();
    });
  });

  describe("logging", () => {

    const runtimeContext = generateRuntimePluginContext(pluginContext);

    const wrappedEmbeddable: IEmbeddableContextOptions = {
      container: document.createElement("div"),
      laraJson: {
        name: "Test Interactive",
        type: "MwInteractive",
        ref_id: "86-MwInteractive"
      },
      interactiveStateUrl: "http://interactive.state.url",
      interactiveAvailable: true
    };
    const runtimeContextWithEmbeddable = generateRuntimePluginContext(Object.assign({},
      pluginContext, { wrappedEmbeddable }));

    describe("when logger_utils are available", () => {
      beforeEach(() => {
        (window as any).loggerUtils = {
          log: jest.fn()
        };
      });

      it("delegates log call to loggerUtils", () => {
        const e = { event: "test" };
        runtimeContext.log(e);
        const augmentedE = { event: "test", plugin_id: 123, embeddable_plugin_id: 42};
        expect((window as any).loggerUtils.log).toHaveBeenCalledWith(augmentedE);
      });

      it("delegates log on a simply string log data", () => {
        const logMsg = "What's your favorite log message?";
        runtimeContext.log(logMsg);
        const augmentedLogEvent = { event: logMsg, plugin_id: 123, embeddable_plugin_id: 42};
        expect((window as any).loggerUtils.log).toHaveBeenCalledWith(augmentedLogEvent);
      });

      describe("when there is a wrapped embeddable", () => {
        it("delegates log call to loggerUtils", () => {
          const e = { event: "test" };
          runtimeContextWithEmbeddable.log(e);
          const augmentedEvent = {
            event: "test",
            plugin_id: 123,
            embeddable_plugin_id: 42,
            wrapped_embeddable_type: "MwInteractive",
            wrapped_embeddable_id: "86-MwInteractive"
          };
          expect((window as any).loggerUtils.log).toHaveBeenCalledWith(augmentedEvent);
        });
      });

    });

    describe("when logger_utils are not available", () => {
      beforeEach(() => {
        (window as any).loggerUtils = undefined;
      });

      it("does not fail, just quietly ignore the call", () => {
        const e = { event: "test" };
        runtimeContext.log(e);
      });
    });

  });

});

describe("Plugin authoring context helper", () => {
  beforeEach(() => {
    fetch.resetMocks();
  });

  const pluginContext: IPluginAuthoringContextOptions = {
    type: "authoring",
    name: "test",
    url: "http://plugin.url",
    pluginId: 123,
    authoredState: "{authoredState: 123}",
    container: document.createElement("div"),
    componentLabel: "test",
    authorDataSaveUrl: "http://author-data.save.url",
    firebaseJwtUrl: "http://firebase.jwt.url",
    portalJwtUrl: "http://fake.jwt",
    wrappedEmbeddable: null
  };

  it("should copy basic properties to runtime context", () => {
    const authoringContext = generateAuthoringPluginContext(pluginContext);
    expect(authoringContext.name).toEqual(pluginContext.name);
    expect(authoringContext.url).toEqual(pluginContext.url);
    expect(authoringContext.pluginId).toEqual(pluginContext.pluginId);
    expect(authoringContext.authoredState).toEqual(pluginContext.authoredState);
    expect(authoringContext.container).toEqual(pluginContext.container);
  });

  describe("#saveAuthorData", () => {
    const authoringContext = generateAuthoringPluginContext(pluginContext);
    const authorData = '{"new": "data"}';
    let ajax = jest.fn();
    beforeEach(() => {
      ajax = jest.fn((opts) => {
        opts.success(authorData);
      });
      jest.spyOn($, "ajax").mockImplementation(ajax);
    });

    describe("when save succeeds", () => {
      it("should save data", () => {
        expect.assertions(1);
        return authoringContext.saveAuthoredPluginState(authorData)
          .then((d) => expect(d).toEqual(authorData));
      });
    });

    describe("when save fails", () => {
      beforeEach(() => {
        window.alert = jest.fn();
        ajax = jest.fn((opts) => {
          opts.error("jqXHR", "error", "boom");
        });
        jest.spyOn($, "ajax").mockImplementation(ajax);
      });
      it("should show an alert and return error", () => {
        expect.assertions(2);
        return authoringContext.saveAuthoredPluginState(authorData)
          .catch((e) => {
            expect(window.alert).toBeCalledTimes(1);
            expect(e).toEqual("boom");
          });
      });
    });
  });

});
