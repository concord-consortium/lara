import * as React from "react";
import { useEffect, useRef, useState } from "react";
import * as iframePhone from "iframe-phone";

// Cross-origin trick: the host page is opened on one host name; the iframe is
// pointed at the other. localhost and 127.0.0.1 are different origins for
// same-origin-policy / postMessage purposes, so this yields a real cross-origin
// iframe from a single live-server.
const otherHost = (hostname: string) => (hostname === "localhost" ? "127.0.0.1" : "localhost");
const INTERACTIVE_PATH = "/focus-interactive/index.html";

export const HostComponent: React.FC = () => {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const phoneRef = useRef<iframePhone.ParentEndpoint>();
  const [connected, setConnected] = useState(false);
  const [focusInsideIframe, setFocusInsideIframe] = useState(false);
  const [lastEvent, setLastEvent] = useState("(none)");

  // Allow overriding the embedded interactive with a full URL via the
  // `?interactive=<url>` query param, e.g. to point at testbed/linked-state or
  // an externally hosted interactive. When set, the iframe-phone target origin
  // is derived from that URL; otherwise we fall back to the cross-origin trick
  // (host on one of localhost/127.0.0.1, iframe on the other).
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

  const sentinelStyle: React.CSSProperties = { position: "absolute", width: 0, height: 0, overflow: "hidden" };

  return (
    <div style={{ padding: 16 }}>
      <h1>focus-host — Phase A (baseline, no trap)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | iframeSrc: {iframeSrc} | iframeOrigin: {iframeOrigin} |{" "}
        focusInsideIframe: {String(focusInsideIframe)} | lastEvent: {lastEvent}
      </div>

      <button type="button">Host: Before</button>

      <div id="trap-container" style={{ border: "3px solid green", padding: 8, margin: "8px 0" }}>
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
        <button type="button">Host: Close (escape hatch)</button>
      </div>

      <button type="button">Host: After</button>
    </div>
  );
};
