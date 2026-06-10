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

// Cross-origin trick (same as Phase B focus-host): the host page is opened on one
// host name; the iframe is pointed at the other. The two hosts are different origins
// for same-origin-policy / postMessage purposes, so this yields a real cross-origin
// iframe from a single source. localhost/127.0.0.1 cover the local dev server; the
// models-resources CloudFront domain pairs with its direct S3 URL (both front the
// same bucket) so the deployed testbed is also self-demonstrating. Unknown hosts fall
// back to themselves (same-origin) rather than a broken guess.
const HOST_MAP: Record<string, string> = {
  "localhost": "127.0.0.1",
  "127.0.0.1": "localhost",
  "models-resources.concord.org": "models-resources.s3.amazonaws.com",
  "models-resources.s3.amazonaws.com": "models-resources.concord.org"
};
const otherHost = (hostname: string) => HOST_MAP[hostname] ?? hostname;
const INTERACTIVE_PATH = "/focus-interactive-coop/index.html";

const ENTER_LABEL = "Press Tab to enter the interactive";

export const HostComponent: React.FC = () => {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const phoneRef = useRef<iframePhone.ParentEndpoint>();
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

  // Allow overriding the embedded interactive with a full URL via the
  // `?interactive=<url>` query param (reuses the Phase B mechanism). Default embed
  // is focus-interactive-coop, which speaks the focus protocol => cooperating path;
  // point `?interactive=` at a plain interactive for the non-cooperating fallback.
  const { protocol, hostname, port } = window.location;
  const defaultOrigin = `${protocol}//${otherHost(hostname)}${port ? ":" + port : ""}`;
  const overrideSrc = new URLSearchParams(window.location.search).get("interactive") || undefined;
  const iframeSrc = overrideSrc ?? `${defaultOrigin}${INTERACTIVE_PATH}`;
  const iframeOrigin = overrideSrc ? new URL(overrideSrc).origin : defaultOrigin;

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
    return () => phone.disconnect();
  }, [iframeOrigin]);

  // Observability only: drive the displayed focusInsideIframe + lastEvent from the
  // top-level window blur/focus + activeElement trick (an iframe *element* does not
  // fire focus/blur when focus moves into/out of its nested browsing context). This
  // is independent of the library's own internal `inside` tracking (which the
  // IframeSlot derives from iframe element focus/blur and uses to toggle sentinel
  // tabindex). Here it's purely for the status line.
  useEffect(() => {
    let timer: number | undefined;
    const syncFromActiveElement = () => {
      const inIframe = document.activeElement === iframeRef.current;
      setFocusInsideIframe(inIframe);
      setLastEvent(inIframe ? "focus entered iframe" : "focus left iframe");
    };
    const onWindowBlur = () => { timer = window.setTimeout(syncFromActiveElement, 0); };
    const onWindowFocus = () => { setFocusInsideIframe(false); setLastEvent("focus returned to host"); };
    window.addEventListener("blur", onWindowBlur);
    window.addEventListener("focus", onWindowFocus);
    return () => {
      window.clearTimeout(timer);
      window.removeEventListener("blur", onWindowBlur);
      window.removeEventListener("focus", onWindowFocus);
    };
  }, []);

  // Phase C1: wire the agnostic IframeSlot core imperatively into a
  // FocusTrapController, presented as the Phase B inline dialog.
  //
  //   container (tabIndex 0, the single tile Tab stop)
  //     - wrapper <div>            (the iframe-slot's content element)
  //         - before-sentinel <span>
  //         - iframe               (host-owned tabIndex per below)
  //         - after-sentinel <span>
  //     - neighbor <button>        (normal slot - host chrome)
  //     - close <button>           (normal slot - the escape hatch)
  //
  // The iframe-slot is the FIRST slot. enterTrap() enters its first slot in landing
  // mode (programmatic entry, no pending Tab default), so opening the tile with
  // Enter lands focus on the visible, labeled before-sentinel ("Press Tab to enter
  // the interactive") in a single call. Live-Tab re-entry uses positioner mode.
  //
  // Host owns the iframe's tabIndex across open/closed (the trap's tabindex sweep
  // deliberately skips the iframe-slot wrapper):
  //   - Closed (trap disabled): iframe tabIndex -1 => Tab skips the whole tile.
  //   - Open   (trap enabled + trapped): iframe tabIndex 0 => the sentinel
  //     positioner's native descent can enter it.
  // The library owns the sentinels' tabindex (toggled from focusInsideIframe +
  // getIntercept) and data-landing.
  useEffect(() => {
    const container = containerRef.current;
    const wrapper = wrapperRef.current;
    if (!container || !wrapper || !trapEnabled) {
      return;
    }
    let tearingDown = false;
    // Build-order cycle (onExit -> controller -> strategy -> slot) is broken by
    // constructing the slot first and referencing the later-assigned controller
    // through this closure (same approach as Phase B).
    let controller: FocusTrapController;

    const phone = phoneRef.current;
    const focusManager = phone ? new FocusManager(phone) : undefined;

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
      // sentinel (no shared IframeSlotRegistry in C1).
      getIntercept: () => ({ forward: true, reverse: true }),
      enterLabel: ENTER_LABEL
    });
    slot.attach();

    const unsubscribeCapability = focusManager?.transport.onMessage(msg => {
      if (msg.type === "capability" && msg.focusProtocol) {
        setCooperating(true);
        setLastEvent("capability recv -> cooperating");
      } else if (msg.type === "focusExit") {
        setLastEvent(`focusExit recv {${msg.mode}}`);
      }
    });

    const setIframeEnterable = (enterable: boolean) => {
      const el = iframeRef.current;
      if (el) {
        el.tabIndex = enterable ? 0 : -1;
      }
    };

    const strategy: FocusTrapStrategy = {
      getElements: () => ({
        content: wrapperRef.current ?? undefined,
        neighbor: neighborBtnRef.current ?? undefined,
        close: closeBtnRef.current ?? undefined,
        restore: restoreBtnRef.current ?? undefined
      }),
      cycleOrder: ["content", "neighbor", "close", "restore"],
      contentSlot: "content",
      nativeTabSlots: ["content"],
      focusContent: (ctx: FocusContentContext) => slot.focusContent(ctx),
      getNativeTabSlotSentinels: () => slot.getSentinels()
    };

    controller = new FocusTrapController(container, strategy);

    // Re-close (disable) the trap whenever it exits, so Tab on the container passes
    // through instead of re-engaging, and put the iframe back out of the Tab order.
    // Guarded so the teardown-time exit doesn't fight destroy()'s own restoration.
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

    // Restore stand-in for AP's post-overlay glue: ask the interactive to re-focus
    // its last-focused control. Cooperating => focusEnter{restore} (precise);
    // non-cooperating => the library's forward landing-hint fallback.
    const onRestoreClick = () => {
      setLastEvent("restore (requestRestore)");
      slot.requestRestore();
    };
    restoreBtnRef.current?.addEventListener("click", onRestoreClick);

    // Inline-tile dismiss: while the trap is open, if focus moves to an element
    // OUTSIDE the tile (e.g. the user clicks "Host: Before"), release the trap so
    // it doesn't stay stuck "open" (which would no-op the next Enter and leave the
    // iframe Tab-reachable). This is the host's modality responsibility — mirrors
    // what selection-driven hosts like CLUE do via setEnabled(false). Release with
    // { refocus: false } so focus stays where the user clicked, not yanked back to
    // the container. The iframe is inside the container and native descent into it
    // fires no parent focusin, so this never false-triggers on iframe entry.
    const onDocFocusIn = (e: FocusEvent) => {
      if (!controller.isTrapped) {
        return;
      }
      const target = e.target as Node | null;
      if (target && container.contains(target)) {
        return;
      }
      controller.exitTrap({ refocus: false }); // fires strategy.onExit (closes + iframe -1)
      setLastEvent("dismiss (focus left tile)");
    };
    document.addEventListener("focusin", onDocFocusIn, true);

    return () => {
      tearingDown = true;
      container.removeEventListener("keydown", onContainerKeyDown);
      document.removeEventListener("focusin", onDocFocusIn, true);
      restoreBtnRef.current?.removeEventListener("click", onRestoreClick);
      unsubscribeCapability?.();
      focusManager?.destroy();
      slot.detach();
      controller.destroy();
    };
  }, [trapEnabled]);

  const handleTrapToggle = (e: React.ChangeEvent<HTMLInputElement>) => setTrapEnabled(e.target.checked);

  return (
    <div style={{ padding: 16 }}>
      {/* Landing reveal: the sentinels are visually-hidden but focusable; the
          library sets [data-landing] on one of them in landing mode, which reveals
          the static hint text. */}
      <style>{`
        .iframe-sentinel {
          position: absolute;
          width: 1px;
          height: 1px;
          overflow: hidden;
          clip: rect(0 0 0 0);
          white-space: nowrap;
        }
        .iframe-sentinel[data-landing] {
          position: static;
          width: auto;
          height: auto;
          overflow: visible;
          clip: auto;
          white-space: normal;
          display: inline-block;
          padding: 2px 6px;
          background: #ffe;
          border: 1px dashed #888;
          font-style: italic;
        }
      `}</style>

      <h1>focus-host-slot — Phase C2 (iframe-slot, capability-aware)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | cooperating: {String(cooperating)} | iframeSrc: {iframeSrc} |{" "}
        iframeOrigin: {iframeOrigin} | focusInsideIframe: {String(focusInsideIframe)} |{" "}
        lastEvent: {lastEvent}
      </div>

      <label style={{ display: "block", marginBottom: 4 }}>
        <input type="checkbox" checked={trapEnabled} onChange={handleTrapToggle} />{" "}
        trap enabled
      </label>
      <p style={{ marginTop: 0, marginBottom: 8, fontStyle: "italic" }}>
        The green tile is a single Tab stop: Tab moves past it without entering. Press
        Enter on it to go inside. With a cooperating embed (the default
        focus-interactive-coop) focus lands precisely on the interactive's first control
        and Escape inside the interactive exits the tile; with a non-cooperating embed
        (<code>?interactive=</code> a plain interactive) you get the Phase&nbsp;C1
        "Press Tab to enter" landing hint instead. "Restore focus" asks a cooperating
        interactive to re-focus its last control. Uncheck "trap enabled" for the native
        (no-trap) baseline.
      </p>

      <button type="button">Host: Before (outside trap)</button>

      <div ref={containerRef} id="trap-container" tabIndex={0} style={{ border: "3px solid green", padding: 8, margin: "8px 0" }}>
        <div ref={wrapperRef} data-slot="content" style={{ position: "relative" }}>
          <span ref={beforeSentinelRef} data-sentinel="before" className="iframe-sentinel" tabIndex={-1}>
            {ENTER_LABEL}
          </span>
          <iframe
            ref={iframeRef}
            src={iframeSrc}
            title="embedded interactive"
            width="100%"
            height={320}
            tabIndex={-1}
          />
          <span ref={afterSentinelRef} data-sentinel="after" className="iframe-sentinel" tabIndex={-1}>
            {ENTER_LABEL}
          </span>
        </div>
        <button ref={neighborBtnRef} type="button">Host: trapped neighbor</button>
        <button ref={closeBtnRef} type="button">Host: Close (escape hatch)</button>
        <button ref={restoreBtnRef} type="button">Host: Restore focus (AP-glue stand-in)</button>
      </div>

      <button type="button">Host: After (outside trap)</button>
    </div>
  );
};
