import * as events from "./events";

describe("Events helper", () => {
  describe("Log event", () => {
    it("provides working API for event handling", () => {
      const handler = jest.fn();
      events.onLog(handler);
      const e = { event: "test" };
      events.emitLog(e);
      expect(handler).toHaveBeenNthCalledWith(1, e);
      events.offLog(handler);
      events.emitLog(e);
      expect(handler).toHaveBeenNthCalledWith(1, e);
    });
  });

  describe("ClickToPlayStarted event", () => {
    it("provides working API for event handling", () => {
      const handler = jest.fn();
      events.onClickToPlayStarted(handler);
      const e = { container: document.createElement("div") };
      events.emitClickToPlayStarted(e);
      expect(handler).toHaveBeenNthCalledWith(1, e);
      events.offClickToPlayStarted(handler);
      events.emitClickToPlayStarted(e);
      expect(handler).toHaveBeenNthCalledWith(1, e);
    });
  });
});
