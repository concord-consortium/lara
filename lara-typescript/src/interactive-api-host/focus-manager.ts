import { FocusEnterMode, FocusExitMode } from "../interactive-api-shared/types";

/**
 * Structurally-compatible mirror of accessibility-tools' FocusMessage / FocusTransport
 * (§7 of iframe-slot-design.md). The library stays concord-dependency-free, so this
 * host adapter defines its own vocabulary and maps the wire messages to/from it.
 * Because the shapes match, the testbed host can pass FocusManager.transport straight
 * into the library's IframeSlot (structural typing bridges the two).
 */
export type FocusMessage =
  | { type: "focusEnter"; mode: FocusEnterMode }
  | { type: "focusExit"; mode: FocusExitMode }
  | { type: "capability"; focusProtocol: boolean }
  | { type: "trapStateChanged"; active: boolean }
  | { type: "focusReady" };

export interface FocusTransport {
  send: (msg: FocusMessage) => void;
  /** Subscribe; returns an unsubscribe function. */
  onMessage: (cb: (msg: FocusMessage) => void) => () => void;
}

/** The slice of an iframe-phone ParentEndpoint that FocusManager needs. */
export interface IFocusPhone {
  post: (message: string, content?: any) => void;
  addListener: (message: string, callback: (content?: any) => void) => void;
  removeListener: (message: string) => void;
}

/**
 * Adapts an iframe-phone endpoint into a FocusTransport for the iframe-slot.
 *
 * Outbound: focusEnter -> phone.post("focusEnter", { mode }).
 * Inbound:  "focusExit" wire message -> { type: "focusExit", mode }.
 *
 * Capability is NOT read from a phone listener here. iframe-phone allows only ONE
 * listener per message name, and `supportedFeatures` is already owned by the host
 * (it carries interactiveState, etc.). So the FocusManager must not add its own
 * `supportedFeatures` listener — it would silently clobber the host's. Instead the
 * host forwards the capability via `notifyCapability()` from its single listener.
 * See "iframe-phone has one listener per message" in the cooperating design doc.
 *
 * Capability still flows out through onMessage (not a separate API) so the IframeSlot's
 * own handleMessage consumes it. The last capability is cached and replayed to any
 * subscriber that attaches after it arrived (the slot may subscribe late).
 */
export class FocusManager {
  public readonly transport: FocusTransport;
  private phone: IFocusPhone;
  private subscribers = new Set<(msg: FocusMessage) => void>();
  private lastCapability: { focusProtocol: boolean } | null = null;

  constructor(phone: IFocusPhone) {
    this.phone = phone;

    phone.addListener("focusExit", (content?: { mode?: FocusExitMode }) => {
      if (content && content.mode) {
        this.emit({ type: "focusExit", mode: content.mode });
      }
    });

    this.transport = {
      send: (msg: FocusMessage) => {
        if (msg.type === "focusEnter") {
          this.phone.post("focusEnter", { mode: msg.mode });
        }
        // focusExit / capability are inbound-only from the host's perspective.
      },
      onMessage: (cb: (msg: FocusMessage) => void) => {
        this.subscribers.add(cb);
        if (this.lastCapability) {
          cb({ type: "capability", focusProtocol: this.lastCapability.focusProtocol });
        }
        return () => { this.subscribers.delete(cb); };
      }
    };
  }

  /**
   * Push the interactive's focus-protocol capability in from the host. The host owns
   * the single `supportedFeatures` listener (iframe-phone is one-listener-per-message),
   * so it calls this from that listener instead of the FocusManager grabbing its own.
   * Emits a `capability` FocusMessage and caches it for replay to late subscribers.
   */
  public notifyCapability(focusProtocol: boolean): void {
    // Cache and emit BOTH values. The consumer (accessibility-tools IframeSlot) defaults
    // to non-cooperating, so a `false` is redundant on first report -- but an interactive
    // can flip from cooperating to non-cooperating (e.g. it navigates itself to a page
    // that no longer speaks the protocol) on the SAME FocusManager. Without emitting the
    // `false`, the slot would stay cooperating and route an entry to an interactive that
    // no longer listens. Replaying the latest value (true or false) keeps a late
    // subscriber in sync too.
    this.lastCapability = { focusProtocol };
    this.emit({ type: "capability", focusProtocol });
  }

  public destroy(): void {
    this.phone.removeListener("focusExit");
    this.subscribers.clear();
  }

  private emit(msg: FocusMessage): void {
    this.subscribers.forEach(cb => cb(msg));
  }
}
