import * as LaraInteractiveApi from "./index";
import { useLaraInteractiveApi } from "./index";

describe("LaraInteractiveApi", () => {
  it("should export the Client class", () => {
    expect(LaraInteractiveApi.Client).toBeDefined();
  });

  it("should export the inIFrame function", () => {
    expect(LaraInteractiveApi.inIframe).toBeDefined();
    expect(typeof LaraInteractiveApi.inIframe).toBe("function");
    expect(LaraInteractiveApi.inIframe()).toBe(false);
  });

  it("should export the useLaraInteractiveApi function", () => {
    expect(useLaraInteractiveApi).toBeDefined();
  });

});
