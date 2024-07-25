import * as RubricAuthoring from "./index";

describe("RubricAuthoring API", () => {
  it("should export all the API functions", () => {
    expect(RubricAuthoring.renderRubricForm).toBeDefined();
  });
});
