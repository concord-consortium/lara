import * as LaraInteractiveApi from "./index";
import { useLaraInteractiveApi } from "./index";

describe("LaraInteractiveApi", () => {
  it("should export the Client class", () => {
    expect(LaraInteractiveApi.Client).toBeDefined();
  });

  it("should export the InIFrame constant", () => {
    expect(LaraInteractiveApi.InIframe).toBeDefined();
    expect(LaraInteractiveApi.InIframe).toBe(false);
  });

  it("should export the useLaraInteractiveApi function", () => {
    expect(useLaraInteractiveApi).toBeDefined();
  });

});
