import * as React from "react";
import { useEffect, useRef, useState } from "react";
import * as iframePhone from "iframe-phone";
import { FocusTrapController, FocusTrapStrategy } from "@concord-consortium/accessibility-tools/hooks";

// Cross-origin trick: the host page is opened on one host name; the iframe is
// pointed at the other. The two hosts are different origins for same-origin-policy /
// postMessage purposes, so this yields a real cross-origin iframe from a single
// source. localhost/127.0.0.1 cover the local dev server; the models-resources
// CloudFront domain pairs with its direct S3 URL (both front the same bucket) so the
// deployed testbed is also self-demonstrating. Unknown hosts fall back to themselves
// (same-origin) rather than a broken guess.
const HOST_MAP: Record<string, string> = {
  "localhost": "127.0.0.1",
  "127.0.0.1": "localhost",
  "models-resources.concord.org": "models-resources.s3.amazonaws.com",
  "models-resources.s3.amazonaws.com": "models-resources.concord.org"
};
const otherHost = (hostname: string) => HOST_MAP[hostname] ?? hostname;
// Relative to the examples root (the host page and the interactive are sibling
// folders). Kept path-prefix-relative so the embed resolves both locally (served at
// "/") and deployed under a prefix like "/lara-example-interactives/branch/<name>/".
const INTERACTIVE_PATH = "focus-interactive/index.html";

export const HostComponent: React.FC = () => {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const phoneRef = useRef<iframePhone.ParentEndpoint>();
  const [connected, setConnected] = useState(false);
  const [focusInsideIframe, setFocusInsideIframe] = useState(false);
  const [lastEvent, setLastEvent] = useState("(none)");
  const containerRef = useRef<HTMLDivElement>(null);
  const beforeBtnRef = useRef<HTMLButtonElement>(null);
  const closeBtnRef = useRef<HTMLButtonElement>(null);
  const [trapEnabled, setTrapEnabled] = useState(true);

  // Allow overriding the embedded interactive with a full URL via the
  // `?interactive=<url>` query param, e.g. to point at testbed/linked-state or
  // an externally hosted interactive. When set, the iframe-phone target origin
  // is derived from that URL; otherwise we fall back to the cross-origin trick
  // (host on one of localhost/127.0.0.1, iframe on the other).
  const { protocol, hostname, port } = window.location;
  const defaultOrigin = `${protocol}//${otherHost(hostname)}${port ? ":" + port : ""}`;
  // The examples root is the parent of this page's own directory (host and interactive
  // are siblings): "/" locally, "/lara-example-interactives/branch/<name>/" deployed.
  const pageDir = window.location.pathname.replace(/[^/]+$/, "");
  const examplesRoot = pageDir.replace(/[^/]+\/$/, "");
  const overrideSrc = new URLSearchParams(window.location.search).get("interactive") || undefined;
  const iframeSrc = overrideSrc ?? `${defaultOrigin}${examplesRoot}${INTERACTIVE_PATH}`;
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

  // Hand-track focusInsideIframe. An iframe *element* does NOT fire focus/blur
  // when focus moves into/out of its nested browsing context, so we can't listen
  // on the element. The reliable cross-origin signal is on the top-level window:
  // when focus enters the subframe the window fires `blur` and
  // document.activeElement becomes the iframe element (readable even
  // cross-origin); when focus returns to the host the window fires `focus`.
  // We read activeElement on a deferred tick because some browsers update it
  // just after the blur event fires.
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

  // Phase B: wrap the container in the CURRENT FocusTrapController, with the
  // iframe as an ordinary slot. This is expected to mishandle the iframe — that
  // failure is the point of this phase.
  //
  // We present the trap like an inline dialog so it can be demonstrated on a
  // single page without becoming a keyboard dead-end:
  //   - "closed" = controller DISABLED. In this mode the library makes the
  //     trap's contents non-tabbable (so Tab skips them) AND does not intercept
  //     Tab on the container, so Tab moves past it to the next control. The
  //     container itself is a single focusable Tab stop (tabIndex 0).
  //   - Enter on the focused container "opens" the trap: enable + enterTrap()
  //     focuses the first slot and Tab then cycles within the trap.
  //   - Escape (handled by the controller) exits; our onExit closes it back to
  //     the disabled state so Tab passes through again.
  // When the "trap enabled" toggle is off we skip the controller entirely, so
  // native traversal (Phase A) returns.
  useEffect(() => {
    const container = containerRef.current;
    if (!container || !trapEnabled) {
      return;
    }
    let tearingDown = false;
    const strategy: FocusTrapStrategy = {
      getElements: () => ({
        before: beforeBtnRef.current ?? undefined,
        iframe: iframeRef.current ?? undefined,
        close: closeBtnRef.current ?? undefined
      }),
      cycleOrder: ["before", "iframe", "close"]
    };
    const controller = new FocusTrapController(strategy);
    controller.containerRef(container); // attach the DOM seam (two-phase ctor)
    // Re-close (disable) the trap whenever it exits, so Tab on the container
    // passes through instead of re-engaging. Guarded so the teardown-time exit
    // doesn't fight destroy()'s own tabindex restoration.
    strategy.onExit = () => {
      if (!tearingDown) {
        controller.setEnabled(false);
      }
    };
    controller.setEnabled(false); // start "closed"

    const onContainerKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Enter" && e.target === container && !controller.isTrapped) {
        e.preventDefault();
        controller.setEnabled(true);
        controller.enterTrap();
      }
    };
    container.addEventListener("keydown", onContainerKeyDown);

    return () => {
      tearingDown = true;
      container.removeEventListener("keydown", onContainerKeyDown);
      controller.destroy();
    };
  }, [trapEnabled]);

  const sentinelStyle: React.CSSProperties = { position: "absolute", width: 0, height: 0, overflow: "hidden" };

  const handleTrapToggle = (e: React.ChangeEvent<HTMLInputElement>) => setTrapEnabled(e.target.checked);

  return (
    <div style={{ padding: 16 }}>
      <h1>focus-host — Phase B (existing trap, iframe-blind)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | iframeSrc: {iframeSrc} | iframeOrigin: {iframeOrigin} |{" "}
        focusInsideIframe: {String(focusInsideIframe)} | lastEvent: {lastEvent}
      </div>

      <label style={{ display: "block", marginBottom: 4 }}>
        <input type="checkbox" checked={trapEnabled} onChange={handleTrapToggle} />{" "}
        trap enabled
      </label>
      <p style={{ marginTop: 0, marginBottom: 8, fontStyle: "italic" }}>
        The green container is a single Tab stop: Tab moves past it to the next control
        without entering. Press Enter on it to open the trap (focuses the first control
        inside; Tab then cycles within). Press Escape to close back to the container.
      </p>

      <button type="button">Host: Before (outside trap)</button>

      <div ref={containerRef} id="trap-container" tabIndex={0} style={{ border: "3px solid green", padding: 8, margin: "8px 0" }}>
        <button ref={beforeBtnRef} type="button">Host: trapped neighbor</button>
        {/* Sentinels are present but inert in Phase A (tabIndex -1). They become active in Phase C. */}
        <span data-sentinel="before" tabIndex={-1} style={sentinelStyle} />
        <iframe
          ref={iframeRef}
          src={iframeSrc}
          title="embedded interactive"
          width="100%"
          height={320}
          tabIndex={0}
        />
        <span data-sentinel="after" tabIndex={-1} style={sentinelStyle} />
        <button ref={closeBtnRef} type="button">Host: Close (escape hatch)</button>
      </div>

      <button type="button">Host: After (outside trap)</button>
    </div>
  );
};
