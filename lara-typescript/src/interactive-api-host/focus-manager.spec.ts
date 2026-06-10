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

  it("translates supportedFeatures.focusProtocol into a capability message", () => {
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    phone.fakeMessage("supportedFeatures", { apiVersion: 1, features: { focusProtocol: true } });
    expect(received).toEqual([{ type: "capability", focusProtocol: true }]);
  });

  it("does not emit capability when focusProtocol is absent/false", () => {
    const received: FocusMessage[] = [];
    manager.transport.onMessage(m => received.push(m));
    phone.fakeMessage("supportedFeatures", { apiVersion: 1, features: { interactiveState: true } });
    expect(received).toEqual([]);
  });

  it("replays capability to a subscriber that attaches AFTER it arrived", () => {
    phone.fakeMessage("supportedFeatures", { apiVersion: 1, features: { focusProtocol: true } });
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
    expect(phone.hasListener("supportedFeatures")).toBe(false);
  });
});
