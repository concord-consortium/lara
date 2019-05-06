import { generatePluginRuntimeContext } from "./plugin-runtime-context";
import { initPlugin, registerPlugin } from "./plugins";
import * as $ from "jquery";

describe("Plugins", () => {
  beforeEach(() => {
    // Lots of errors logging, so that way we can avoid extensive errors being logged to console and add some
    // additional checks in tests.
    (window as any).console = {
      log: jest.fn(),
      error: jest.fn(),
      info: jest.fn(),
      group: jest.fn(),
      groupEnd: jest.fn(),
      dir: jest.fn()
    };
  });

  describe("registerPlugin", () => {
    it ("should let plugin to register itself only once", () => {
      const pluginConstructor = jest.fn();
      expect(registerPlugin("test", pluginConstructor)).toEqual(true);
      expect(registerPlugin("test", pluginConstructor)).toEqual(false);
      // @ts-ignore
      expect(registerPlugin("anotherTest")).toEqual(false); // missing constructor
      // tslint:disable-next-line:no-console
      expect(console.error).toHaveBeenCalledTimes(2);
    });
  });

  describe("initPlugin", () => {
    const pluginId = 123;
    const context = {
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
      wrappedEmbeddable: null
    };

    it("should call the plugins constructor with the config", () => {
      const pluginConstructor = jest.fn();
      // Implicit test of registerPlugin
      registerPlugin("testPlugin1", pluginConstructor);
      initPlugin("testPlugin1", context);
      expect(pluginConstructor).toHaveBeenCalledTimes(1);
      // Why keys? Some functions are dynamically generated and we cannot compare them.
      expect(Object.keys(pluginConstructor.mock.calls[0][0])).toEqual(
        Object.keys(generatePluginRuntimeContext(context))
      );
    });

    it("should gracefully handle plugin constructor error (not to break the whole JS page execution)", () => {
      const constructorFunc = jest.fn();
      class BrokenPlugin {
        constructor() {
          constructorFunc();
          throw new Error("Random error");
        }
      }
      registerPlugin("testPlugin2", BrokenPlugin);
      initPlugin("testPlugin2", context);
      expect(constructorFunc).toHaveBeenCalledTimes(1);
      // tslint:disable-next-line:no-console
      expect(console.error).toHaveBeenCalledTimes(1);
    });
  });
});
