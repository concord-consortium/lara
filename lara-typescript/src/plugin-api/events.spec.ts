import { events } from "./events";
import * as EventsImpl from "../lib/events";

describe("Events", () => {
  it("should delegate methods to events lib", () => {
    jest.spyOn(EventsImpl, "onLog");
    jest.spyOn(EventsImpl, "offLog");
    jest.spyOn(EventsImpl, "onInteractiveAvailable");
    jest.spyOn(EventsImpl, "offInteractiveAvailable");
    const handler = jest.fn();
    events.onLog(handler);
    expect(EventsImpl.onLog).toHaveBeenCalledWith(handler);
    events.offLog(handler);
    expect(EventsImpl.offLog).toHaveBeenCalledWith(handler);
    events.onInteractiveAvailable(handler);
    expect(EventsImpl.onInteractiveAvailable).toHaveBeenCalledWith(handler);
    events.offInteractiveAvailable(handler);
    expect(EventsImpl.offInteractiveAvailable).toHaveBeenCalledWith(handler);
  });
});
