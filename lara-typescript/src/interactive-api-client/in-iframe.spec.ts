import { inIframe } from "./in-frame";

describe("in-iframe", () => {
  it("should export inIframe function", () => {
    expect(inIframe).toBeDefined();
    expect(typeof inIframe).toBe("function");
    expect(inIframe()).toBe(false);
  });
});
