import { events } from "./events";
import * as EventsImpl from "../lib/events";

describe("Events", () => {
  it("should delegate methods to events lib", () => {
    jest.spyOn(EventsImpl, "onLog");
    jest.spyOn(EventsImpl, "offLog");
    jest.spyOn(EventsImpl, "onClickToPlayStarted");
    jest.spyOn(EventsImpl, "offClickToPlayStarted");
    const handler = jest.fn();
    events.onLog(handler);
    expect(EventsImpl.onLog).toHaveBeenCalledWith(handler);
    events.offLog(handler);
    expect(EventsImpl.offLog).toHaveBeenCalledWith(handler);
    events.onClickToPlayStarted(handler);
    expect(EventsImpl.onClickToPlayStarted).toHaveBeenCalledWith(handler);
    events.offClickToPlayStarted(handler);
    expect(EventsImpl.offClickToPlayStarted).toHaveBeenCalledWith(handler);
  });
});
