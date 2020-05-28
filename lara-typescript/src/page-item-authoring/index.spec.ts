import * as PageItemAuthoring from "./index";

describe("Page Item Authoring", () => {
  it("should export all the needed functions", () => {
    expect(PageItemAuthoring.ManagedInteractiveAuthoring).toBeDefined();
    expect(PageItemAuthoring.renderManagedInteractiveAuthoring).toBeDefined();

    expect(PageItemAuthoring.MWInteractiveAuthoring).toBeDefined();
    expect(PageItemAuthoring.renderMWInteractiveAuthoring).toBeDefined();

    expect(PageItemAuthoring.InteractiveAuthoringPreview).toBeDefined();
    expect(PageItemAuthoring.renderInteractiveAuthoringPreview).toBeDefined();
  });
});
