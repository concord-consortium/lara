import * as InternalAPI from "./index";

describe("Plugin API", () => {
  it("should export all the API functions", () => {
    expect(InternalAPI.initPlugin).toBeDefined();
    expect(InternalAPI.events).toBeDefined();
  });
});
