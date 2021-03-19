import { events } from "./events";
import * as EventsImpl from "../events";

describe("Events", () => {
  it("should delegate methods to events lib", () => {
    jest.spyOn(EventsImpl, "onLog");
    jest.spyOn(EventsImpl, "offLog");
    jest.spyOn(EventsImpl, "onInteractiveAvailable");
    jest.spyOn(EventsImpl, "offInteractiveAvailable");
    jest.spyOn(EventsImpl, "onInteractiveSupportedFeatures");
    jest.spyOn(EventsImpl, "offInteractiveSupportedFeatures");
    jest.spyOn(EventsImpl, "onPluginSyncRequest");
    jest.spyOn(EventsImpl, "offPluginSyncRequest");
    const handler = jest.fn();
    events.onLog(handler);
    expect(EventsImpl.onLog).toHaveBeenCalledWith(handler);
    events.offLog(handler);
    expect(EventsImpl.offLog).toHaveBeenCalledWith(handler);
    events.onInteractiveAvailable(handler);
    expect(EventsImpl.onInteractiveAvailable).toHaveBeenCalledWith(handler);
    events.offInteractiveAvailable(handler);
    expect(EventsImpl.offInteractiveAvailable).toHaveBeenCalledWith(handler);
    events.onInteractiveSupportedFeatures(handler);
    expect(EventsImpl.onInteractiveSupportedFeatures).toHaveBeenCalledWith(handler);
    events.offInteractiveSupportedFeatures(handler);
    expect(EventsImpl.offInteractiveSupportedFeatures).toHaveBeenCalledWith(handler);
    events.onPluginSyncRequest(handler);
    expect(EventsImpl.onPluginSyncRequest).toHaveBeenCalledWith(handler);
    events.offPluginSyncRequest(handler);
    expect(EventsImpl.offPluginSyncRequest).toHaveBeenCalledWith(handler);
  });
});
