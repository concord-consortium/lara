import { registerPlugin } from "./plugins";
import * as PluginsImpl from "../lib/plugins";

describe("Plugins", () => {
  it("should delegate registerPlugin", () => {
    const label = "test";
    const PluginConstructor = jest.fn();
    jest.spyOn(PluginsImpl, "registerPlugin");
    PluginsImpl.setNextPluginLabel(label);
    const result = registerPlugin(label, PluginConstructor);
    expect(PluginsImpl.registerPlugin).toHaveBeenCalledWith(label, PluginConstructor);
    expect(result).toBe(true);
  });
});
