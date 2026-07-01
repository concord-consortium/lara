import * as React from "react";
import { useEffect, useRef, useState } from "react";
import * as iframePhone from "iframe-phone";
import {
  FocusContentContext,
  FocusTrapController,
  FocusTrapStrategy,
  IframeSlot
} from "@concord-consortium/accessibility-tools/hooks";
import { FocusManager } from "../../../interactive-api-host";

const ENTER_LABEL = "Press Tab to enter the interactive";

export type SlotName = "content" | "neighbor" | "close" | "restore";

export interface FocusTileProps {
  title: string;
  iframeSrc: string;
  iframeOrigin: string;
  // cycleOrder + which host-chrome buttons render. "content" is always present and
  // is the contentSlot / sole nativeTabSlot. A single-element ["content"] makes the
  // iframe-slot the only slot in the trap (the AP "no host chrome" case).
  slots: SlotName[];
}

// One self-contained focus trap: container (single Tab stop) wrapping the iframe-slot
// (before-sentinel / iframe / after-sentinel) plus optional host-chrome slots. The
// whole trap is wired imperatively the same way the focus-host demo did it, now
// parameterized by `slots` so a tile can be full-chrome or single-slot.
export const FocusTile: React.FC<FocusTileProps> = ({ title, iframeSrc, iframeOrigin, slots }) => {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const phoneRef = useRef<iframePhone.ParentEndpoint>();
  const focusManagerRef = useRef<FocusManager>();
  const [connected, setConnected] = useState(false);
  const [focusInsideIframe, setFocusInsideIframe] = useState(false);
  const [lastEvent, setLastEvent] = useState("(none)");

  const containerRef = useRef<HTMLDivElement>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);
  const beforeSentinelRef = useRef<HTMLSpanElement>(null);
  const afterSentinelRef = useRef<HTMLSpanElement>(null);
  const neighborBtnRef = useRef<HTMLButtonElement>(null);
  const closeBtnRef = useRef<HTMLButtonElement>(null);
  const restoreBtnRef = useRef<HTMLButtonElement>(null);
  const [trapEnabled, setTrapEnabled] = useState(true);
  const [cooperating, setCooperating] = useState(false);
  // Read-only readout of the entering-sentinel landing state for this tile, so the
  // single-slot stuck-on-invisible-sentinel case is visible: data-show-hint=yes means
  // the "Press Tab to enter" hint is shown; data-show-hint=no while focus rests on the
  // before-sentinel is the bug.
  const [landing, setLanding] = useState("data-show-hint=no, activeEl=other");

  const tile = slots.length === 1 ? "single" : "full";

  // Connect the iframe-phone parent endpoint and send a minimal runtime init.
  useEffect(() => {
    const el = iframeRef.current;
    if (!el) {
      return;
    }
    const phone = new iframePhone.ParentEndpoint(el, iframeOrigin, () => {
      setConnected(true);
      phone.post("initInteractive", {
        version: 1,
        mode: "runtime",
        authoredState: {},
        interactiveState: {},
        globalInteractiveState: {}
      });
    });
    phoneRef.current = phone;

    // The FocusManager lives for the phone's lifetime, NOT the trap's. The interactive
    // advertises `supportedFeatures` only once at init, so the focus-capability capture
    // (and the FocusManager's replay cache) must outlive `trapEnabled` toggles. If it
    // were rebuilt per-toggle, re-enabling the trap would create a fresh FocusManager
    // that never re-hears the capability, and the slot would revert to non-cooperating.
    // The HOST owns the single `supportedFeatures` listener (iframe-phone is
    // one-listener-per-message) and forwards the capability via notifyCapability(); the
    // testbed has no other handler, so this stands in for a real host's handler.
    const focusManager = new FocusManager(phone);
    focusManagerRef.current = focusManager;
    phone.addListener("supportedFeatures", (content?: { features?: { focusProtocol?: boolean } }) => {
      focusManager.notifyCapability(!!content?.features?.focusProtocol);
    });
    const unsubscribeCapability = focusManager.transport.onMessage(msg => {
      if (msg.type === "capability") {
        setCooperating(msg.focusProtocol);
        setLastEvent(`capability recv -> ${msg.focusProtocol ? "cooperating" : "non-cooperating"}`);
      } else if (msg.type === "focusExit") {
        setLastEvent(`focusExit recv {${msg.mode}}`);
      }
    });

    return () => {
      unsubscribeCapability();
      phone.removeListener("supportedFeatures");
      focusManager.destroy();
      focusManagerRef.current = undefined;
      phone.disconnect();
    };
  }, [iframeOrigin]);

  // Observability only: drive focusInsideIframe + lastEvent from the top-level window
  // blur/focus + activeElement trick (an iframe *element* does not fire focus/blur
  // when focus moves into/out of its nested browsing context). Guarded with
  // wasInsideRef so that focus moving into ANOTHER tile's iframe (which blurs the
  // window for every tile on the page) does not spam this tile's status line.
  const wasInsideRef = useRef(false);
  useEffect(() => {
    let timer: number | undefined;
    const syncFromActiveElement = () => {
      const inIframe = document.activeElement === iframeRef.current;
      if (inIframe) {
        wasInsideRef.current = true;
        setFocusInsideIframe(true);
        setLastEvent("focus entered iframe");
      } else if (wasInsideRef.current) {
        wasInsideRef.current = false;
        setFocusInsideIframe(false);
        setLastEvent("focus left iframe");
      }
    };
    const onWindowBlur = () => { timer = window.setTimeout(syncFromActiveElement, 0); };
    const onWindowFocus = () => {
      if (wasInsideRef.current) {
        wasInsideRef.current = false;
        setFocusInsideIframe(false);
        setLastEvent("focus returned to host");
      }
    };
    window.addEventListener("blur", onWindowBlur);
    window.addEventListener("focus", onWindowFocus);
    return () => {
      window.clearTimeout(timer);
      window.removeEventListener("blur", onWindowBlur);
      window.removeEventListener("focus", onWindowFocus);
    };
  }, []);

  // Read this tile's sentinels' data-show-hint + the active element on every focus
  // change and whenever data-show-hint flips, and publish it to the status line.
  // Each tile reads only its OWN sentinels, so there is no cross-talk between tiles.
  useEffect(() => {
    const updateLanding = () => {
      const before = beforeSentinelRef.current;
      const after = afterSentinelRef.current;
      const active = document.activeElement;
      const dataLanding = !!(before?.hasAttribute("data-show-hint") || after?.hasAttribute("data-show-hint"));
      let activeEl = "other";
      if (active === before) {
        activeEl = "before-sentinel";
      } else if (active === after) {
        activeEl = "after-sentinel";
      } else if (active === iframeRef.current) {
        activeEl = "iframe";
      }
      setLanding(`data-show-hint=${dataLanding ? "yes" : "no"}, activeEl=${activeEl}`);
    };
    document.addEventListener("focusin", updateLanding, true);
    const observers: MutationObserver[] = [];
    [beforeSentinelRef.current, afterSentinelRef.current].forEach(el => {
      if (el) {
        const mo = new MutationObserver(updateLanding);
        mo.observe(el, { attributes: true, attributeFilter: ["data-show-hint"] });
        observers.push(mo);
      }
    });
    updateLanding();
    return () => {
      document.removeEventListener("focusin", updateLanding, true);
      observers.forEach(o => o.disconnect());
    };
  }, []);

  // Wire the agnostic IframeSlot core imperatively into a FocusTrapController. The
  // iframe-slot is the FIRST slot; cycleOrder = `slots`. With slots === ["content"]
  // the iframe-slot is the only slot, so Tabbing out of the iframe wraps back to its
  // own entering sentinel.
  useEffect(() => {
    const container = containerRef.current;
    const wrapper = wrapperRef.current;
    if (!container || !wrapper || !trapEnabled) {
      return;
    }
    let tearingDown = false;
    let controller: FocusTrapController;

    // The FocusManager and its `supportedFeatures` capability capture live in the phone
    // effect (they outlive trap toggles); the trap only consumes its transport. The
    // FocusManager caches the last capability and replays it to late subscribers, so a
    // slot rebuilt by re-enabling the trap still learns the interactive cooperates.
    const focusManager = focusManagerRef.current;

    const slot = new IframeSlot({
      slotName: "content",
      getIframe: () => iframeRef.current,
      getBeforeSentinel: () => beforeSentinelRef.current,
      getAfterSentinel: () => afterSentinelRef.current,
      onExit: (dir: 1 | -1) => {
        setLastEvent(`sentinel exit ${dir > 0 ? "+1" : "-1"} -> cycle`);
        controller.cycleToAdjacentSlot(dir);
      },
      // Cooperating escape: the interactive's focusExit{escape} arrives via the
      // transport; release the trap with the DEFAULT refocus (focus was inside,
      // so it lands back on the visible tile container).
      onRequestExit: () => {
        setLastEvent("focusExit{escape} -> exitTrap");
        controller.exitTrap();
      },
      transport: focusManager?.transport,
      // Single-iframe constant: always intercept both directions with a tabbable
      // sentinel (no shared IframeSlotRegistry here).
      getIntercept: () => ({ forward: true, reverse: true }),
      enterLabel: ENTER_LABEL
    });
    slot.attach();

    const setIframeEnterable = (enterable: boolean) => {
      const el = iframeRef.current;
      if (el) {
        el.tabIndex = enterable ? 0 : -1;
      }
    };

    const strategy: FocusTrapStrategy = {
      // getElements returns refs for all possible slots; unrendered chrome buttons
      // have null refs (=> undefined) and findNextSlot skips them. cycleOrder is the
      // `slots` prop, so a single-slot tile only cycles "content".
      getElements: () => ({
        content: wrapperRef.current ?? undefined,
        neighbor: neighborBtnRef.current ?? undefined,
        close: closeBtnRef.current ?? undefined,
        restore: restoreBtnRef.current ?? undefined
      }),
      cycleOrder: slots,
      contentSlot: "content",
      nativeTabSlots: ["content"],
      focusContent: (ctx: FocusContentContext) => slot.focusContent(ctx),
      getNativeTabSlotSentinels: () => slot.getSentinels()
    };

    controller = new FocusTrapController(strategy);
    controller.containerRef(container); // attach the DOM seam (two-phase ctor)

    // Re-close (disable) the trap whenever it exits, so Tab on the container passes
    // through instead of re-engaging, and put the iframe back out of the Tab order.
    strategy.onExit = () => {
      if (!tearingDown) {
        setIframeEnterable(false);
        controller.setEnabled(false);
        setLastEvent("close (trap exit)");
      }
    };

    controller.setEnabled(false); // start "closed"
    setIframeEnterable(false);     // closed: iframe out of the Tab order

    const onContainerKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Enter" && e.target === container && !controller.isTrapped) {
        e.preventDefault();
        setIframeEnterable(true);   // open: iframe can be descended into
        controller.setEnabled(true);
        controller.enterTrap();     // iframe-slot is first => lands in landing mode
        setLastEvent("open (enterTrap -> landing)");
      }
    };
    container.addEventListener("keydown", onContainerKeyDown);

    // Restore stand-in for AP's post-overlay glue (only present when the tile renders
    // a restore button; otherwise the ref is null and this no-ops).
    const onRestoreClick = () => {
      setLastEvent("restore (requestRestore)");
      slot.requestRestore();
    };
    restoreBtnRef.current?.addEventListener("click", onRestoreClick);

    // Inline-tile dismiss: while trapped, if focus moves OUTSIDE this tile's
    // container, release the trap so it does not stay stuck "open". Release with
    // { refocus: false } so focus stays where it went.
    const onDocFocusIn = (e: FocusEvent) => {
      if (!controller.isTrapped) {
        return;
      }
      const target = e.target as Node | null;
      if (target && container.contains(target)) {
        return;
      }
      controller.exitTrap({ refocus: false });
      setLastEvent("dismiss (focus left tile)");
    };
    document.addEventListener("focusin", onDocFocusIn, true);

    return () => {
      tearingDown = true;
      container.removeEventListener("keydown", onContainerKeyDown);
      document.removeEventListener("focusin", onDocFocusIn, true);
      restoreBtnRef.current?.removeEventListener("click", onRestoreClick);
      slot.detach();
      controller.destroy();
    };
  }, [trapEnabled]);

  const handleTrapToggle = (e: React.ChangeEvent<HTMLInputElement>) => setTrapEnabled(e.target.checked);

  return (
    <section data-trap={tile} style={{ marginBottom: 24 }}>
      <h2>{title}</h2>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | cooperating: {String(cooperating)} |{" "}
        focusInsideIframe: {String(focusInsideIframe)} | landing: {landing} |{" "}
        lastEvent: {lastEvent}
      </div>

      <label style={{ display: "block", marginBottom: 4 }}>
        <input type="checkbox" checked={trapEnabled} onChange={handleTrapToggle} />{" "}
        trap enabled
      </label>

      <button type="button">Host: Before (outside trap)</button>

      <div ref={containerRef} tabIndex={0} style={{ border: "3px solid green", padding: 8, margin: "8px 0" }}>
        <div ref={wrapperRef} data-slot="content" style={{ position: "relative" }}>
          <span ref={beforeSentinelRef} data-sentinel="before" className="iframe-sentinel" tabIndex={-1}>
            {ENTER_LABEL}
          </span>
          <iframe
            ref={iframeRef}
            src={iframeSrc}
            title={`embedded interactive (${tile})`}
            width="100%"
            height={320}
            tabIndex={-1}
          />
          <span ref={afterSentinelRef} data-sentinel="after" className="iframe-sentinel" tabIndex={-1}>
            {ENTER_LABEL}
          </span>
        </div>
        {slots.includes("neighbor") &&
          <button ref={neighborBtnRef} type="button">Host: trapped neighbor</button>}
        {slots.includes("close") &&
          <button ref={closeBtnRef} type="button">Host: Close (escape hatch)</button>}
        {slots.includes("restore") &&
          <button ref={restoreBtnRef} type="button">Host: Restore focus (AP-glue stand-in)</button>}
      </div>

      <button type="button">Host: After (outside trap)</button>
    </section>
  );
};
