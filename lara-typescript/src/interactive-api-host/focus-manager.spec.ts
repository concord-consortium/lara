import { FocusManager, FocusMessage, IFocusPhone } from "./focus-manager";

class MockPhone implements IFocusPhone {
  public posts: Array<{ message: string; content: any }> = [];
  private listeners: Record<string, (content?: any) => void> = {};
  public post(message: string, content?: any) { this.posts.push({ message, content }); }
  public addListener(message: string, callback: (content?: any) => void) { this.listeners[message] = callback; }
  public removeListener(message: string) { delete this.listeners[message]; }
  public fakeMessage(message: string, content?: any) { this.listeners[message]?.(content); }
  public hasListener(message: string) { return !!this.listeners[message]; }
}

describe("FocusManager", () => {
  let phone: MockPhone;
  let manager: FocusManager;
  beforeEach(() => { phone = new MockPhone(); manager = new FocusManager(phone); });

  it("send(focusEnter) posts a focusEnter wire message", () => {
    manager.transport.send({ type: "focusEnter", mode: "forward" });
    expect(phone.posts).toEqual([{ message: "focusEnter", content: { mode: "forward" } }]);
  });

  it("never posts for inbound-only message types", () => {
    manager.transport.send({ type: "capability", focusProtocol: true });
    expect(phone.posts).toEqual([]);
  });

  it("translates inbound focusExit into a FocusMessage", () => {
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    phone.fakeMessage("focusExit", { mode: "escape" });
    expect(received).toEqual([{ type: "focusExit", mode: "escape" }]);
  });

  it("does NOT add a supportedFeatures listener (host owns that message)", () => {
    // iframe-phone is one-listener-per-message; the FocusManager must not claim the
    // host's supportedFeatures listener. Capability arrives via notifyCapability().
    expect(phone.hasListener("supportedFeatures")).toBe(false);
  });

  it("notifyCapability(true) emits a capability message", () => {
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    manager.notifyCapability(true);
    expect(received).toEqual([{ type: "capability", focusProtocol: true }]);
  });

  it("notifyCapability(false) emits a capability message", () => {
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    manager.notifyCapability(false);
    expect(received).toEqual([{ type: "capability", focusProtocol: false }]);
  });

  it("caches the LATEST capability for replay when it flips true -> false", () => {
    manager.notifyCapability(true);
    manager.notifyCapability(false);
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    expect(received).toEqual([{ type: "capability", focusProtocol: false }]);
  });

  it("replays capability to a subscriber that attaches AFTER notifyCapability", () => {
    manager.notifyCapability(true);
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    expect(received).toEqual([{ type: "capability", focusProtocol: true }]);
  });

  it("unsubscribe stops delivery; destroy removes phone listeners", () => {
    const received: FocusMessage[] = [];
    const unsubscribe = manager.transport.onMessage(m => received.push(m));
    unsubscribe();
    phone.fakeMessage("focusExit", { mode: "escape" });
    expect(received).toEqual([]);
    manager.destroy();
    expect(phone.hasListener("focusExit")).toBe(false);
  });
});
