import * as Plugins from "./plugins";
import { generateRuntimeContext } from "../helpers/runtime-context";
import * as $ from "jquery";

describe("Plugins", () => {
  it("should exist", () => {
    expect(Plugins).toBeDefined();
  });

  describe("initPlugin", () => {
    const name = "myPlugin";
    const pluginId = "123";
    const pluginConstructor = jest.fn();
    const context = {
      name,
      pluginId,
      url: "http://google.com/",
      pluginStateKey: "123",
      authoredState: '{"configured": true }',
      learnerState: '{"answered": true }',
      learnerStateSaveUrl: "http://learner.save",
      div: $('<div class="myplugin" />')[0],
      runId: 123,
      userEmail: "",
      classInfoUrl: "",
      remoteEndpoint: "",
      interactiveStateUrl: "",
      firebaseJwtUrl: "http://fake.jwt",
      wrappedEmbeddableDiv: undefined,
      wrappedEmbeddableContext: null,
      experimental: {
        clickToPlayId: null
      }
    };

    beforeAll(() => {
      // Implicit test of registerPlugin
      Plugins.registerPlugin(name, pluginConstructor);
      Plugins.initPlugin(name, context);
    });

    it("should call the plugins constructor with the config", () => {
      expect(pluginConstructor).toHaveBeenCalledTimes(1);
      // Why keys? Some functions are dynamically generated and we cannot compare them.
      expect(Object.keys(pluginConstructor.mock.calls[0][0])).toEqual(Object.keys(generateRuntimeContext(context)));
    });

    describe("saveLearnerPluginState", () => {
      const state = '{"new": "state"}';
      let ajax = jest.fn();
      beforeEach(() => {
        ajax = jest.fn((opts) => {
          opts.success(state);
        });
        jest.spyOn($, "ajax").mockImplementation(ajax);
      });

      describe("When save succeeds", () => {
        it("should save data", () => {
          expect.assertions(1);
          return Plugins.saveLearnerPluginState(pluginId, state)
            .then((d) => expect(d).toEqual(state));
        });
      });

      describe("When save fails", () => {
        beforeEach(() => {
          ajax = jest.fn((opts) => {
            opts.error("jqXHR", "error", "boom");
          });
          jest.spyOn($, "ajax").mockImplementation(ajax);
        });
        it("should save data", () => {
          expect.assertions(1);
          return Plugins.saveLearnerPluginState(pluginId, state)
            .catch((e) => expect(e).toEqual("boom"));
        });
      });
    });
  });
});
