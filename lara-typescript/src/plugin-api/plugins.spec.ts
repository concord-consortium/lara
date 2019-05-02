import * as Plugins from "./plugins";
import { generatePluginRuntimeContext } from "../internal-api/plugin-runtime-context";
import { initPlugin } from "../internal-api/plugins";
import * as $ from "jquery";

describe("Plugins", () => {
  it("should exist", () => {
    expect(Plugins).toBeDefined();
  });

  describe("initPlugin", () => {
    const name = "myPlugin";
    const pluginId = 123;
    const pluginConstructor = jest.fn();
    const context = {
      name,
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

    beforeAll(() => {
      // Implicit test of registerPlugin
      Plugins.registerPlugin(name, pluginConstructor);
      initPlugin(name, context);
    });

    it("should call the plugins constructor with the config", () => {
      expect(pluginConstructor).toHaveBeenCalledTimes(1);
      // Why keys? Some functions are dynamically generated and we cannot compare them.
      expect(Object.keys(pluginConstructor.mock.calls[0][0])).toEqual(
        Object.keys(generatePluginRuntimeContext(context))
      );
    });
  });
});
