import * as Projects from "./index";

describe("Projects API", () => {
  it("should export all the API functions", () => {
    expect(Projects.renderProjectList).toBeDefined();
    expect(Projects.renderProjectSettingsForm).toBeDefined();
  });
});
