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
 * Inbound:  "focusExit" wire message            -> { type: "focusExit", mode }
 *           "supportedFeatures" w/ focusProtocol -> { type: "capability", focusProtocol: true }
 *
 * Capability flows through onMessage (not a separate API) so the IframeSlot's own
 * handleMessage consumes it. The last capability is cached and replayed to any
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

    phone.addListener("supportedFeatures", (content?: { features?: { focusProtocol?: boolean } }) => {
      const focusProtocol = !!(content && content.features && content.features.focusProtocol);
      if (focusProtocol) {
        this.lastCapability = { focusProtocol: true };
        this.emit({ type: "capability", focusProtocol: true });
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

  public destroy(): void {
    this.phone.removeListener("focusExit");
    this.phone.removeListener("supportedFeatures");
    this.subscribers.clear();
  }

  private emit(msg: FocusMessage): void {
    this.subscribers.forEach(cb => cb(msg));
  }
}
