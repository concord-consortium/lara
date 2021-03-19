import { generateRuntimePluginContext,
         IPluginRuntimeContextOptions,
         IPluginAuthoringContextOptions } from "./plugin-context";
import { initPlugin, registerPlugin, setNextPluginLabel } from "./plugins";
import * as $ from "jquery";

describe("Plugins", () => {
  beforeEach(() => {
    // Lots of errors logging, so that way we can avoid extensive errors being logged to console and add some
    // additional checks in tests.
    (window as any).console = {
      log: jest.fn(),
      error: jest.fn(),
      warn: jest.fn(),
      info: jest.fn(),
      group: jest.fn(),
      groupEnd: jest.fn(),
      dir: jest.fn()
    };
  });

  describe("registerPlugin", () => {
    it ("should let plugin to register itself only once", () => {
      const runtimeClass = jest.fn();
      const authoringClass = jest.fn();
      setNextPluginLabel("test");
      expect(registerPlugin({runtimeClass, authoringClass})).toEqual(true);
      setNextPluginLabel("test");
      expect(registerPlugin({runtimeClass, authoringClass})).toEqual(false);
      // @ts-ignore
      expect(registerPlugin("anotherTest")).toEqual(false); // missing constructor
      // tslint:disable-next-line:no-console
      expect(console.error).toHaveBeenCalledTimes(2);
    });

    it ("should not let plugin register itself without runtime class", () => {
      const authoringClass = jest.fn();
      setNextPluginLabel("testWithoutRuntime");
      // @ts-ignore
      expect(registerPlugin({authoringClass})).toEqual(false);
    });

    it ("should let plugin register itself without authoring class", () => {
      const runtimeClass = jest.fn();
      setNextPluginLabel("testWithoutAuthoring");
      expect(registerPlugin({runtimeClass})).toEqual(true);
    });
  });

  describe("initPlugin", () => {
    const pluginId = 123;
    const runtimeContextOptions: IPluginRuntimeContextOptions = {
      type: "runtime",
      name: "testPlugin",
      pluginId,
      url: "http://google.com/",
      authoredState: '{"configured": true }',
      learnerState: '{"answered": true }',
      learnerStateSaveUrl: "http://learner.save",
      container: $('<div class="myplugin" />')[0],
      runId: 123,
      userEmail: null,
      classInfoUrl: null,
      remoteEndpoint: null,
      firebaseJwtUrl: "http://fake.jwt",
      embeddablePluginId: null,
      wrappedEmbeddable: null,
      componentLabel: "test",
      resourceUrl: "http://lara.activity.com/123",
      offlineMode: false
    };
    const authoringContextOptions: IPluginAuthoringContextOptions = {
      type: "authoring",
      name: "testPlugin",
      pluginId,
      url: "http://google.com/",
      authoredState: '{"configured": true }',
      container: $('<div class="myplugin" />')[0],
      componentLabel: "test",
      authorDataSaveUrl: "http://authoring.save",
      firebaseJwtUrl: "http://firebase.jwt",
      wrappedEmbeddable: null
    };

    it("should call the plugins constructor with the config", () => {
      const runtimeClass = jest.fn();
      const authoringClass = jest.fn();
      // Implicit test of registerPlugin
      setNextPluginLabel("testPlugin1");
      registerPlugin({runtimeClass, authoringClass});
      initPlugin("testPlugin1", runtimeContextOptions);
      initPlugin("testPlugin1", authoringContextOptions);
      expect(runtimeClass).toHaveBeenCalledTimes(1);
      expect(authoringClass).toHaveBeenCalledTimes(1);
      // Why keys? Some functions are dynamically generated and we cannot compare them.
      expect(Object.keys(runtimeClass.mock.calls[0][0])).toEqual(
        Object.keys(generateRuntimePluginContext(runtimeContextOptions))
      );
    });

    it("should gracefully handle plugin constructor error (not to break the whole JS page execution)", () => {
      const runtimeConstructor = jest.fn();
      const authoringConstructor = jest.fn();
      class BrokenRuntimePlugin {
        constructor() {
          runtimeConstructor();
          throw new Error("Random error");
        }
      }
      class BrokenAuthoringPlugin {
        constructor() {
          authoringConstructor();
          throw new Error("Random error");
        }
      }
      setNextPluginLabel("testPlugin2");
      registerPlugin({runtimeClass: BrokenRuntimePlugin, authoringClass: BrokenAuthoringPlugin});
      initPlugin("testPlugin2", runtimeContextOptions);
      initPlugin("testPlugin2", authoringContextOptions);
      expect(runtimeConstructor).toHaveBeenCalledTimes(1);
      expect(authoringConstructor).toHaveBeenCalledTimes(1);
      // tslint:disable-next-line:no-console
      expect(console.error).toHaveBeenCalledTimes(2);
    });
  });
});
