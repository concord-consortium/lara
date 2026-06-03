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

  const { protocol, hostname, port } = window.location;
  const iframeOrigin = `${protocol}//${otherHost(hostname)}${port ? ":" + port : ""}`;
  const iframeSrc = `${iframeOrigin}${INTERACTIVE_PATH}`;

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

  // Hand-track focusInsideIframe from the iframe element's focus/blur — the one
  // cross-origin signal the parent can observe. (focus/blur do not bubble, so
  // listen directly on the element.)
  useEffect(() => {
    const el = iframeRef.current;
    if (!el) {
      return;
    }
    const onFocus = () => { setFocusInsideIframe(true); setLastEvent("iframe focus"); };
    const onBlur = () => { setFocusInsideIframe(false); setLastEvent("iframe blur"); };
    el.addEventListener("focus", onFocus);
    el.addEventListener("blur", onBlur);
    return () => {
      el.removeEventListener("focus", onFocus);
      el.removeEventListener("blur", onBlur);
    };
  }, []);

  const sentinelStyle: React.CSSProperties = { position: "absolute", width: 0, height: 0, overflow: "hidden" };

  return (
    <div style={{ padding: 16 }}>
      <h1>focus-host — Phase A (baseline, no trap)</h1>
      <div style={{ fontFamily: "monospace", marginBottom: 12 }}>
        connected: {String(connected)} | iframeOrigin: {iframeOrigin} | focusInsideIframe:{" "}
        {String(focusInsideIframe)} | lastEvent: {lastEvent}
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
