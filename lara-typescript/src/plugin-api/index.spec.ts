import * as LARA from "./index";

describe("LARA API", () => {
  it("should export all the API functions", () => {
    expect(LARA).toBeDefined();
    expect(LARA.registerPlugin).toBeDefined();
    expect(LARA.addSidebar).toBeDefined();
    expect(LARA.addPopup).toBeDefined();
    expect(LARA.decorateContent).toBeDefined();
    expect(LARA.log).toBeDefined();
    expect(LARA.events).toBeDefined();
  });
});
