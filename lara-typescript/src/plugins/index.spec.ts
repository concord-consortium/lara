import * as Plugins from "./index";

describe("Plugin API", () => {
  it("should export all the API functions", () => {
    expect(Plugins.initPlugin).toBeDefined();
    expect(Plugins.setNextPluginLabel).toBeDefined();
  });
});
