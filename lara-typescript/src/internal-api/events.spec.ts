import { events } from "./events";

describe("Events", () => {
  it("should delegate methods to events lib", () => {
    expect(events.emitLog).toBeDefined();
    expect(events.emitInteractiveAvailable).toBeDefined();
  });
});
