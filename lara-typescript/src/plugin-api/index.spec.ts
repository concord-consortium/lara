import * as PluginAPI from "./index";

describe("Plugin API", () => {
  it("should export all the API functions", () => {
    expect(PluginAPI.registerPlugin).toBeDefined();
    expect(PluginAPI.addSidebar).toBeDefined();
    expect(PluginAPI.addPopup).toBeDefined();
    expect(PluginAPI.decorateContent).toBeDefined();
    expect(PluginAPI.log).toBeDefined();
    expect(PluginAPI.events).toBeDefined();
  });
});
