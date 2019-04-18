import * as Plugins from "./plugins";
import * as $ from "jquery";

describe("Plugins", () => {
  it("should exist", () => {
    expect(Plugins).toBeDefined();
  });

  describe("initPlugin", () => {
    const name = "myPlugin";
    const pluginId = "123";
    const pluginStatePaths = {
      savePath: "save/1/2",
      loadPath: "load/1/2"
    };
    const pluginConstructor = jest.fn();

    const config = {
      name,
      pluginId,
      url: "http://google.com/",
      pluginStateKey: "123",
      authoredState: '{"configured": true }',
      learnerState: '{"answered": true }',
      div: $('<div class="myplugin" />')[0],
      runID: 123,
      userEmail: "",
      classInfoUrl: "",
      remoteEndpoint: "",
      interactiveStateUrl: "",
      getFirebaseJwtUrl: () => "http://fake.jwt",
      wrappedEmbeddableDiv: undefined,
      wrappedEmbeddableContext: null,
      experimental: {
        clickToPlayId: null
      }
    };

    beforeAll(() => {
      // Implicit test of registerPlugin
      Plugins.registerPlugin(name, pluginConstructor);
      Plugins.initPlugin(name, config, pluginStatePaths);
    });

    it("should call the plugins constructor with the config", () => {
      expect(pluginConstructor).toHaveBeenCalledTimes(1);
      expect(pluginConstructor).toHaveBeenCalledWith(config);
    });

    it("should maintain a list of plugins", () => {
      expect(Plugins.pluginLabels).toContain(name);
      expect(Plugins.pluginStatePaths[pluginId]).toEqual(pluginStatePaths);
      expect(Plugins.pluginClasses[name]).toEqual(pluginConstructor);
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
