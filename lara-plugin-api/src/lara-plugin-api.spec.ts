import * as LARA from "./lara-plugin-api";

describe("LARA API", () => {
  it("should export all the API functions", () => {
    expect(LARA).toBeDefined();
    expect(LARA.registerPlugin).toBeDefined();
    expect(LARA.initPlugin).toBeDefined();
    expect(LARA.addSidebar).toBeDefined();
    expect(LARA.addPopup).toBeDefined();
    expect(LARA.decorateContent).toBeDefined();
  });
});
