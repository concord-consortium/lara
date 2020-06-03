import * as LaraInteractiveApi from "./index";

describe("LaraInteractiveApi", () => {
  it("should export the inIFrame function", () => {
    expect(LaraInteractiveApi.inIframe).toBeDefined();
    expect(typeof LaraInteractiveApi.inIframe).toBe("function");
    expect(LaraInteractiveApi.inIframe()).toBe(false);
  });
});
