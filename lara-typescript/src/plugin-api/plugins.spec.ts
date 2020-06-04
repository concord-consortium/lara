import { registerPlugin } from "./plugins";
import * as PluginsImpl from "../plugins/plugins";

describe("Plugins", () => {
  it("should delegate registerPlugin", () => {
    const label = "test";
    const runtimeClass = jest.fn();
    const authoringClass = jest.fn();
    jest.spyOn(PluginsImpl, "registerPlugin");
    PluginsImpl.setNextPluginLabel(label);
    const result = registerPlugin({runtimeClass, authoringClass});
    expect(PluginsImpl.registerPlugin).toHaveBeenCalledWith({runtimeClass, authoringClass});
    expect(result).toBe(true);
  });
});
