import { log } from "./log";

describe("Log", () => {
  describe("when logger_utils are available", () => {
    beforeEach(() => {
      (window as any).loggerUtils = {
        log: jest.fn()
      };
    });

    it("delegates log call to loggerUtils", () => {
      const e = { event: "test" };
      log(e);
      expect((window as any).loggerUtils.log).toHaveBeenCalledWith(e);
    });
  });

  describe("when logger_utils are not available", () => {
    beforeEach(() => {
      (window as any).loggerUtils = undefined;
    });

    it("does not fail, just quietly ignore the call", () => {
      const e = { event: "test" };
      log(e);
    });
  });
});
